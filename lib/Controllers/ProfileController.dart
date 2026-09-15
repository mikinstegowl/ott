import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/AuthChopperService.dart';
import 'package:ottapp/Models/ProfileModel.dart';
import 'package:ottapp/Controllers/BaseController.dart';
import 'package:ottapp/Constants/CustomSnackBar.dart';

class ProfileController extends BaseController {
  final AuthChopperService authChopperService;

  ProfileController({required this.authChopperService});

  var profileModel = Rxn<ProfileModel>();
  
  // Controllers for editing
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  var preferredQuality = "auto".obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    if (isGuest) return;
    showLoader(true);
    try {
      final response = await authChopperService.getMeAPI();
      if (response.isSuccessful && response.body != null) {
        profileModel.value = response.body;
        _populateControllers();
      }
    } catch (e) {
      Utility.showSnackBar("Failed to load profile", isError: true, response: e);
    } finally {
      showLoader(false);
    }
  }

  void _populateControllers() {
    final data = profileModel.value?.data;
    if (data != null) {
      nameController.text = data.name ?? "";
      emailController.text = data.email ?? "";
      phoneController.text = data.phone ?? "";
      preferredQuality.value = data.preferredQuality ?? "auto";
    }
  }

  Future<void> updateProfile() async {
    if (newPasswordController.text.isNotEmpty && 
        newPasswordController.text != confirmPasswordController.text) {
      Utility.showSnackBar("Passwords do not match", isError: true);
      return;
    }

    if (newPasswordController.text.isNotEmpty && currentPasswordController.text.isEmpty) {
      Utility.showSnackBar("Current password is required to change password", isError: true);
      return;
    }

    showLoader(true);
    try {
      bool isError = false;

      final profileParams = {
        "name": nameController.text,
        "email": emailController.text,
        "phone": phoneController.text,
        "preferred_quality": preferredQuality.value,
      };

      final profileResponse = await authChopperService.updateProfileAPI(param: profileParams);
      if (!profileResponse.isSuccessful) {
        isError = true;
        Utility.showSnackBar("Failed to update profile", isError: true, response: profileResponse);
      }

      if (newPasswordController.text.isNotEmpty && !isError) {
        final passParams = {
          "current_password": currentPasswordController.text,
          "password": newPasswordController.text,
          "password_confirmation": confirmPasswordController.text,
        };
        final passResponse = await authChopperService.changePasswordAPI(param: passParams);
        if (passResponse.isSuccessful) {
          currentPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();
        } else {
          isError = true;
          Utility.showSnackBar("Failed to change password", isError: true, response: passResponse);
        }
      }

      if (!isError) {
        Utility.showSnackBar("Profile updated successfully");
        fetchProfileData();
      }
    } catch (e) {
      Utility.showSnackBar("An error occurred", isError: true, response: e);
    } finally {
      showLoader(false);
    }
  }

  // LogOut is now handled by BaseController

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
