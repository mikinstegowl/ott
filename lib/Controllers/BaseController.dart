import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Router/RouterName.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Models/ProfileModel.dart';
import 'package:ottapp/ChopperClientService/AuthChopperService.dart';
import 'package:ottapp/Network/AppChopperClient.dart';
import 'package:ottapp/SharedPreferences/PrefKeys.dart';
import 'package:ottapp/SharedPreferences/shared_preferences.dart';

import 'package:ottapp/Widgets/AppTextFieldWidget.dart';
import 'package:ottapp/Widgets/InAppPurchase/InAppPurchaseBottomSheet.dart';
import 'package:ottapp/Constants/CustomSnackBar.dart';

class BaseController extends GetxController {
  RxBool isLoading = false.obs;
  final Rx<ProfileModel?> profileData = Rxn<ProfileModel>();
  static final RxBool isSubscribed = false.obs;

  bool get isGuest =>
      UserPreference.getValue(key: PrefKeys.skipUser) == true ||
      (Platform.isIOS && UserPreference.getValue(key: PrefKeys.logInToken) == null);

  void showLoader(bool value) {
    isLoading.value = value;
  }

  // Base control for players (Generic)
  void initializePlayer(dynamic player, String url, {bool autoPlay = true}) {
    // Media Kit specific logic removed. 
    // Video Player initialization is now handled in specific controllers.
  }

  Future<void> fetchUserProfile() async {
    if (isGuest) return;

    // Optimization: Don't re-fetch if we already have the data
    if (profileData.value != null) return;

    try {
      final authService = AppChopperClient().getChopperService<AuthChopperService>();
      final response = await authService.getMeAPI();
      if (response.isSuccessful && response.body != null) {
        profileData.value = response.body;
      }
    } catch (e) {
      print("BaseController: Error fetching profile: $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize global subscription status
    isSubscribed.value = UserPreference.getBool(key: PrefKeys.subscriptionStatus) ?? false;
    // Fetch profile data globally on initialization
    fetchUserProfile();
  }

  void logOut() {
    UserPreference.removeKey(key: PrefKeys.logInToken);
    Get.offAllNamed(RoutesName.logInScreen);
  }

  Future<void> deleteAccount() async {
    final passwordController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.white10),
            ),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.appColors.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: AppColors.appColors,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 20.h),
              const AppTextWidget(
                text: "Delete Account?",
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 12.h),
              const AppTextWidget(
                text: "Are you sure you want to delete your account? This action is permanent and cannot be undone.",
                color: AppColors.lightWhite70,
                fontSize: 14,
                textAlign: TextAlign.center,
                maxLines: null,
                overflow: TextOverflow.visible,
              ),
              SizedBox(height: 20.h),
              AppTextFieldWidget(
                controller: passwordController,
                hintText: "Enter Current Password",
                obscureText: true,
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const AppTextWidget(
                        text: "Cancel",
                        color: AppColors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (passwordController.text.isEmpty) {
                          Utility.showSnackBar("Password is required", isError: true);
                          return;
                        }

                        Get.back(); // Close dialog
                        showLoader(true);
                        try {
                          final authService = AppChopperClient().getChopperService<AuthChopperService>();
                          final response = await authService.deleteAccountAPI(param: {
                            "password": passwordController.text,
                            "confirmation": "DELETE",
                          });
                          if (response.isSuccessful) {
                            UserPreference.removeKey(key: PrefKeys.logInToken);
                            Get.offAllNamed(RoutesName.logInScreen);
                            Utility.showSnackBar("Your account has been successfully deleted.");
                          } else {
                            Utility.showSnackBar("Failed to delete account. Please try again.", isError: true, response: response);
                          }
                        } catch (e) {
                          Utility.showSnackBar("An error occurred", isError: true, response: e);
                        } finally {
                          showLoader(false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appColors,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: const AppTextWidget(
                        text: "Delete",
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  void showSubscriptionDialog({
    required String title,
    required String description,
    required String buttonText,
    String? plansUrl,
  }) {
    if (isClosed) return;
    showLoader(false);
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.appColors.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.appColors,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 20.h),
              AppTextWidget(
                text: title,
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 12.h),
              AppTextWidget(
                text: description,
                color: AppColors.lightWhite70,
                fontSize: 14,
                textAlign: TextAlign.center,
                maxLines: null,
                overflow: TextOverflow.visible,
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const AppTextWidget(
                        text: "Not Now",
                        color: AppColors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        final context = Get.context;
                        if (context != null) {
                          InAppPurchaseBottomSheet.show(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appColors,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: AppTextWidget(
                        text: buttonText,
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void showLoginDialog() {
    if (isClosed) return;
    showLoader(false);
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.white10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.appColors.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.login_rounded,
                    color: AppColors.appColors,
                    size: 40.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                const AppTextWidget(
                  text: "Login Required",
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 12.h),
                const AppTextWidget(
                  text: "To play this content or interact, you must login.",
                  color: AppColors.lightWhite70,
                  fontSize: 14,
                  textAlign: TextAlign.center,
                  maxLines: null,
                  overflow: TextOverflow.visible,
                ),
                SizedBox(height: 30.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: const AppTextWidget(
                          text: "Cancel",
                          color: AppColors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          UserPreference.removeKey(key: PrefKeys.skipUser);
                          Get.offAllNamed(RoutesName.logInScreen);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.appColors,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: const AppTextWidget(
                          text: "Login",
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
