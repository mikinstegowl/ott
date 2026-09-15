import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Const/AppText.dart';
import 'package:ottapp/Constants/AppLoader.dart';
import 'package:ottapp/Controllers/LoginController.dart';
import 'package:ottapp/Router/RouterName.dart';
import 'package:ottapp/Widgets/AppTextFieldWidget.dart';
import 'package:ottapp/Widgets/AppPrimaryButton.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image showing movie grid
          Image.asset(
            "assets/image/loginBackground.webp",
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.5),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h).copyWith(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 40.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blackOpacity70,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Center(
                        child: Image.asset(
                          "assets/image/logo.png",
                          height: 150.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 48.h),
                      // Form Fields
                      _buildLabel(AppText.emailAddress),
                      AppTextFieldWidget(
                        controller: controller.emailController,
                        hintText: AppText.enterEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 24.h),

                      _buildLabel(AppText.password),
                      AppTextFieldWidget(
                        controller: controller.passwordController,
                        hintText: AppText.password,
                        obscureText: true,
                      ),
                      SizedBox(height: 48.h),

                      // Login Button
                      AppPrimaryButton(
                        text: AppText.login,
                        onTap: () {
                          controller.login();
                        },
                      ),

                      SizedBox(height: 40.h),

                      // Footer Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppTextWidget(
                            text: AppText.ifYouAreNew,
                            color: AppColors.lightWhite70,
                            fontSize: 14,
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.offAllNamed(RoutesName.registerScreen);
                            },
                            child: AppTextWidget(
                              text: AppText.signUp,
                              color: AppColors.appColors,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // Login as Guest
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              controller.loginAsGuest();
                            },
                            child: AppTextWidget(
                              text: "Login as Guest",
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     AppTextWidget(
                      //       text: AppText.orText,
                      //       color: AppColors.lightWhite70,
                      //       fontSize: 14,
                      //     ),
                      //   ],
                      // ),
                      //
                      // SizedBox(height: 24.h),
                      //
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     AppTextWidget(
                      //       text: AppText.continueWithSub,
                      //       color: AppColors.lightWhite70,
                      //       fontSize: 14,
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Obx(
            () =>
                controller.isLoading.value
                    ? const AppLoader()
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: AppTextWidget(
        text: text,
        color: AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
