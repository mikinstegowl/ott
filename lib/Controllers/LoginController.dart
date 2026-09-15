import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ottapp/ChopperClientService/AuthChopperService.dart';
import 'package:ottapp/Constants/CustomSnackBar.dart';
import 'package:ottapp/Controllers/BaseController.dart';
import 'package:ottapp/Models/LoginModel.dart';
import 'package:ottapp/Router/RouterName.dart';
import 'package:ottapp/SharedPreferences/PrefKeys.dart';
import 'package:ottapp/SharedPreferences/shared_preferences.dart';

class LoginController extends BaseController {
  final AuthChopperService _authChopperService;

  LoginController({required AuthChopperService authChopperService})
    : _authChopperService = authChopperService;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override


  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  LoginModel? loginModel;

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Utility.showSnackBar('Please fill all required fields', isError: true);
      return;
    }

    showLoader(true);
    try {
      final param = {
        'email': emailController.text.trim(),
        'password': passwordController.text,
      };

      final response = await _authChopperService.loginAPI(param: param);

      if (response.statusCode == 200 || response.statusCode == 201) {
        loginModel = response.body;
        UserPreference.setValue(key: PrefKeys.logInToken, value: loginModel?.data?.token ?? '');
        UserPreference.removeKey(key: PrefKeys.skipUser);
        
        // Fetch User Details to get subscription status
        await fetchUserDetails();
        
        Utility.showSnackBar('Login Successful');
        Get.offAllNamed(RoutesName.mainWrapper); // Navigate to home
      } else {
        Utility.showSnackBar('Login Failed', isError: true, response: response);
      }
    } catch (e) {
      Utility.showSnackBar(e.toString(), isError: true, response: e);
    } finally {
      showLoader(false);
    }
  }

  void loginAsGuest() {
    UserPreference.setValue(key: PrefKeys.skipUser, value: true);
    Get.offAllNamed(RoutesName.mainWrapper);
  }

  Future<void> fetchUserDetails() async {
    if (isGuest) return;
    try {
      final response = await _authChopperService.getMeAPI();
      if (response.isSuccessful && response.body != null) {
        final userData = response.body!.data;
        // Save subscription status
        final hasSubscription = userData?.subscription != null;
        await UserPreference.setValue(
          key: PrefKeys.subscriptionStatus,
          value: hasSubscription,
        );
        await UserPreference.setValue(
          key: PrefKeys.userId,
          value: userData?.id ?? 0,
        );
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }
}
