import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Controllers/ProfileController.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Constants/AppLoader.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: AppColors.white),
        //   onPressed: () => Get.back(),
        // ),
        title: AppTextWidget(
          text: "My Profile",
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: AppLoader());
        }

        final data = controller.profileModel.value?.data;
        if (data == null) {
          return const Center(child: AppTextWidget(text: "No profile data found", color: Colors.white));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header
              CircleAvatar(
                radius: 40.r,
                backgroundColor: AppColors.appColors.withAlpha(51),
                foregroundImage: (data.avatar != null && data.avatar!.isNotEmpty)
                    ? NetworkImage(data.avatar!)
                    : null,
                child: AppTextWidget(
                  text: (data.name != null && data.name!.isNotEmpty)
                      ? data.name!.trim().substring(0, 1).toUpperCase()
                      : "U",
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.appColors,
                ),
              ),
              SizedBox(height: 15.h),
              AppTextWidget(
                text: data.name ?? "User Name",
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              AppTextWidget(
                text: data.email ?? "email@example.com",
                color: AppColors.grey500,
                fontSize: 14,
              ),
              SizedBox(height: 30.h),

              // Subscription Details Section
              // _buildSectionTitle("Subscription Details"),
              // SizedBox(height: 10.h),
              // _buildSubscriptionCard(data),
              // SizedBox(height: 30.h),

              // Personal Information Section
              _buildSectionTitle("Personal Information"),
              SizedBox(height: 10.h),
              _buildEditableTile("Full Name", controller.nameController),
              _buildEditableTile("Email Address", controller.emailController, enabled: false),
              _buildEditableTile("Phone Number", controller.phoneController),
              _buildQualitySelector(),
              SizedBox(height: 30.h),

              // Change Password Section
              _buildSectionTitle("Change Password"),
              AppTextWidget(
                text: "(leave blank to keep current)",
                color: AppColors.grey500,
                fontSize: 12,
              ),
              SizedBox(height: 10.h),
              _buildEditableTile("Current Password", controller.currentPasswordController, isPassword: true),
              _buildEditableTile("New Password", controller.newPasswordController, isPassword: true),
              _buildEditableTile("Confirm Password", controller.confirmPasswordController, isPassword: true),
              SizedBox(height: 20.h),

              // Update Profile Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: controller.updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appColors,
                    foregroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: const Text("Update Profile", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 30.h),

              // Account Information removed
              SizedBox(height: 40.h),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: controller.logOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red.withAlpha(30),
                    foregroundColor: AppColors.red,
                    side: BorderSide(color: AppColors.red.withAlpha(100)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: AppTextWidget(
                    text: "Log Out",
                    color: AppColors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: OutlinedButton(
                  onPressed: controller.deleteAccount,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: BorderSide(color: AppColors.red.withAlpha(100)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: AppTextWidget(
                    text: "Delete Account",
                    color: AppColors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 50.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: AppTextWidget(
        text: title,
        color: AppColors.whiteOpacity80,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubscriptionCard(dynamic data) {
    final sub = data.subscription;
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                   Container(
                     padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                     decoration: BoxDecoration(
                       color: AppColors.white10,
                       borderRadius: BorderRadius.circular(12.r),
                     ),
                     child: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Icon(Icons.workspace_premium_rounded, color: AppColors.appColors, size: 14.sp),
                         SizedBox(width: 4.w),
                         AppTextWidget(
                           text: sub?.planName ?? "No Active Plan",
                           color: AppColors.appColors,
                           fontSize: 11,
                           fontWeight: FontWeight.bold,
                         ),
                       ],
                     ),
                   ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.appColors .withValues(alpha: 38),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: AppTextWidget(
                  text: sub?.status?.toUpperCase() ?? "INACTIVE",
                  color: AppColors.appColors,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSubStat("Max Quality", sub?.maxQuality ?? "-"),
              _buildSubStat("Max Screens", sub?.maxScreens?.toString() ?? "-"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubStat(String label, String value) {
    return Column(
      children: [
        AppTextWidget(text: label, color: AppColors.grey500, fontSize: 12),
        SizedBox(height: 4.h),
        AppTextWidget(text: value, color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _buildEditableTile(String label, TextEditingController controller, {bool isPassword = false, bool enabled = true}) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextWidget(text: label, color: AppColors.grey500, fontSize: 12),
          SizedBox(height: 6.h),
          TextField(
            controller: controller,
            obscureText: isPassword,
            enabled: enabled,
            style: TextStyle(color: AppColors.white, fontSize: 14.sp),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white10,
              contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide.none,
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: AppColors.white12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualitySelector() {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextWidget(text: "Preferred Quality", color: AppColors.grey, fontSize: 12),
          SizedBox(height: 6.h),
          Theme(
            data: Theme.of(Get.context!).copyWith(canvasColor: AppColors.grey800),
            child: DropdownButtonFormField<String>(
              initialValue: controller.preferredQuality.value,
              dropdownColor: AppColors.grey800,
              style: TextStyle(color: AppColors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.white10,
                contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 0.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none,
                ),
              ),
              items: ["auto", "720p", "1080p", "4k"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toUpperCase()),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  controller.preferredQuality.value = newValue;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, {Color? textColor}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white10,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppTextWidget(text: label, color: AppColors.grey500, fontSize: 14),
          AppTextWidget(text: value, color: textColor ?? AppColors.white, fontSize: 14, fontWeight: FontWeight.w500),
        ],
      ),
    );
  }

  Widget _buildNavTile(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.white10,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.appColors, size: 20.sp),
                SizedBox(width: 12.w),
                AppTextWidget(text: label, color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ],
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.grey500, size: 14.sp),
          ],
        ),
      ),
    );
  }
}
