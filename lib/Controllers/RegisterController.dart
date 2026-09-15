import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/AuthChopperService.dart';
import 'package:ottapp/Constants/CustomSnackBar.dart';
import 'package:ottapp/Controllers/BaseController.dart';
import 'package:ottapp/Models/RegisterModel.dart';
import 'package:ottapp/Router/RouterName.dart';
import 'package:ottapp/SharedPreferences/PrefKeys.dart';
import 'package:ottapp/SharedPreferences/shared_preferences.dart';

class RegisterController extends BaseController {
  final AuthChopperService _authChopperService;

  RegisterController({required AuthChopperService authChopperService})
    : _authChopperService = authChopperService;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();


  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  RegisterModel? registerModel;

  Future<void> register() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Utility.showSnackBar('Please fill all required fields', isError: true);
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Utility.showSnackBar('Passwords do not match', isError: true);
      return;
    }

    showLoader(true);
    try {
      final param = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'password': passwordController.text,
        'password_confirmation': confirmPasswordController.text,
      };

      final response = await _authChopperService.registerAPI(param: param);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Utility.showSnackBar('Registration Successful');
        registerModel = response.body;
        UserPreference.setValue(key: PrefKeys.logInToken, value: registerModel?.data?.token ?? '');
        UserPreference.removeKey(key: PrefKeys.skipUser);
        Get.offAllNamed(RoutesName.mainWrapper);
      } else {
        Utility.showSnackBar('Registration Failed', isError: true, response: response);
      }
    } catch (e) {
      Utility.showSnackBar(e.toString(), isError: true, response: e);
    } finally {
      showLoader(false);
    }
  }
}
