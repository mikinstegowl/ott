import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:ottapp/Controllers/LiveVideoController.dart';
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Widgets/CustomAppBar.dart';
import 'package:ottapp/Controllers/MainWrapperController.dart';

import 'package:ottapp/Models/ChatMessage.dart';

import 'package:ottapp/Constants/AppUtils.dart';


class LiveVideoScreen extends GetView<LiveVideoController> {
  const LiveVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainWrapperController = Get.find<MainWrapperController>();

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: const CustomAppBar(),
      body: GetBuilder<LiveVideoController>(
        init: controller,
        builder: (context) {
          return Obx(() {
            // Trigger fetch or pause depending on active tab status
            if (mainWrapperController.currentIndex.value == 1) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.lazyFetch();
              });
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.pausePlayback();
              });
            }

            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2. Video Player
                          _buildVideoSection(),

                          // 3. Title & Description
                          _buildInfoSection(),

                          // 4. Live Chat Section
                          _buildChatSection(),

                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildVideoSection() {
    return Container(
      width: double.infinity,
      height: 240.h,
      color: Colors.black,
        child: Obx(() {
          if (controller.hasError.value) {
            return _buildPlayerError();
          }
          if (!controller.isInitialized.value ||
              controller.videoPlayerController == null) {
            return Center(
                child: CircularProgressIndicator(color: AppColors.appColors));
          }
          return Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: controller.videoPlayerController!.value.aspectRatio,
                  child: VideoPlayer(controller.videoPlayerController!),
                ),
              ),
              if (controller.isBuffering.value)
                CircularProgressIndicator(color: AppColors.appColors),
            ],
          );
        }),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Obx(() {
        final data = controller.liveVideoData.value?.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextWidget(
              text: data?.name ?? "Tr3BolPlus Live Video",
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            SizedBox(height: 12.h),
            AppTextWidget(
              text: AppUtils.stripHtml(data?.description ?? "Videos Stream On The Works And Coming Soon | TR3BOL, LLC | For Promotional Use Only, All Rights Reserved."),
              fontSize: 14,
              color: AppColors.lightWhite70,
              maxLines: 5,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildChatSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: AppColors.appColors.withAlpha(38),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10.w),
              AppTextWidget(text: "Live Chat", fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
            ],
          ),
          SizedBox(height: 12.h),
          
          // 1. Reactive Message List
          Container(
            height: 350.h,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(51),
              borderRadius: BorderRadius.circular(5.r),
              border: Border.all(color: AppColors.white10),
            ),
            child: Obx(() {
              if (controller.chatMessages.isEmpty) {
                return Center(
                  child: AppTextWidget(
                    text: "No messages yet. Be the first to say something!",
                    color: AppColors.white24,
                    fontSize: 12,
                    textAlign: TextAlign.center,
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: controller.chatMessages.length,
                reverse: false,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final msg = controller.chatMessages[index];
                  return _buildMessageBubble(msg);
                },
              );
            }),
          ),
          
          SizedBox(height: 20.h),
          
          // 2. Chat Input field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.chatController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Say something...",
                    hintStyle: TextStyle(color: AppColors.white24, fontSize: 14.sp),
                    fillColor: const Color(0xFF1E1E1E),
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Obx(() => ElevatedButton(
                onPressed: controller.isSendingMessage.value 
                    ? null 
                    : () => controller.sendMessage(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appColors,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: controller.isSendingMessage.value
                    ? SizedBox(
                        width: 14.w,
                        height: 14.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.black,
                        ),
                      )
                    : AppTextWidget(text: "Send", fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.black),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    // AS REQUESTED: User on Left, Admin on Right
    final isRight = msg.isAdmin;
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isRight) _buildSmallAvatar(userName: msg.senderName),
              SizedBox(width: 8.w),
              Flexible(
                child: Column(
                  crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppTextWidget(
                          text: msg.senderName,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isRight ? AppColors.appColors : AppColors.white54,
                        ),
                        if (isRight) ...[
                          SizedBox(width: 4.w),
                          Icon(Icons.verified, color: AppColors.appColors, size: 12.sp),
                        ],
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 4.h),
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isRight ? AppColors.appColors.withAlpha(38) : AppColors.white10,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.r),
                          topRight: Radius.circular(12.r),
                          bottomLeft: isRight ? Radius.circular(12.r) : Radius.circular(0),
                          bottomRight: isRight ? Radius.circular(0) : Radius.circular(12.r),
                        ),
                        border: isRight ? Border.all(color: AppColors.appColors.withAlpha(76)) : null,
                      ),
                      child: AppTextWidget(
                        text: msg.message,
                        fontSize: 13,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (isRight) ...[
                SizedBox(width: 8.w),
                _buildSmallAvatar(isAdmin: true, userName: msg.senderName),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallAvatar({bool isAdmin = false, String userName = ""}) {
    return CircleAvatar(
      radius: 14.r,
      backgroundColor: isAdmin ? AppColors.appColors.withAlpha(51) : AppColors.white10,
      child: isAdmin 
          ? Icon(
              Icons.shield,
              color: AppColors.appColors,
              size: 14.sp,
            )
          : AppTextWidget(
              text: userName.isNotEmpty ? userName[0].toUpperCase() : "?",
              color: AppColors.white54,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
    );
  }

  Widget _buildPlayerError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.red, size: 40.sp),
          SizedBox(height: 8.h),
          AppTextWidget(text: controller.errorMessage.value, fontSize: 12, textAlign: TextAlign.center),
          TextButton(onPressed: controller.retry, child: const Text("Retry")),
        ],
      ),
    );
  }
}
