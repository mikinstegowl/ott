import 'package:flutter/material.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ottapp/Const/AppText.dart';
import 'package:ottapp/Constants/AppLoader.dart';
import 'package:ottapp/Controllers/RegisterController.dart';
import 'package:ottapp/Router/RouterName.dart';
import 'package:ottapp/Widgets/AppTextFieldWidget.dart';
import 'package:ottapp/Widgets/AppPrimaryButton.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image (Local asset for cinematic look)
          Image.asset(
            "assets/image/loginBackground.webp",
            fit: BoxFit.cover,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo Asset
                      Center(
                        child: Image.asset(
                          'assets/image/logo.png',
                          height: 150.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 30.h),

                      // Form Fields
                      _buildLabel(AppText.fullName),
                      AppTextFieldWidget(
                        controller: controller.nameController,
                        hintText: AppText.enterName,
                      ),
                      SizedBox(height: 16.h),

                      _buildLabel(AppText.emailAddress),
                      AppTextFieldWidget(
                        controller: controller.emailController,
                        hintText: AppText.enterEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 16.h),

                      _buildLabel(AppText.phoneOptional),
                      AppTextFieldWidget(
                        controller: controller.phoneController,
                        hintText: AppText.enterPhone,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: 16.h),

                      _buildLabel(AppText.password),
                      AppTextFieldWidget(
                        controller: controller.passwordController,
                        hintText: AppText.password,
                        obscureText: true,
                      ),
                      SizedBox(height: 16.h),

                      _buildLabel(AppText.confirmPassword),
                      AppTextFieldWidget(
                        controller: controller.confirmPasswordController,
                        hintText: AppText.confirmPasswordHint,
                        obscureText: true,
                      ),
                      SizedBox(height: 32.h),

                      // Sign Up Button
                      AppPrimaryButton(
                        text: AppText.signUp,
                        onTap: () {
                          controller.register();
                        },
                      ),

                      SizedBox(height: 40.h),

                      // Footer Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppTextWidget(
                            text: AppText.alreadyHaveAccount,
                            color: AppColors.lightWhite70,
                            fontSize: 14,
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.offAllNamed(RoutesName.logInScreen);
                            },
                            child: AppTextWidget(
                              text: AppText.signIn,
                              color: AppColors.appColors,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
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
