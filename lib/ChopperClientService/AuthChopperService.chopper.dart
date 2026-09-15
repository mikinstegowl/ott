// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'AuthChopperService.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$AuthChopperService extends AuthChopperService {
  _$AuthChopperService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = AuthChopperService;

  @override
  Future<Response<LoginModel>> loginAPI({required Map<String, dynamic> param}) {
    final Uri $url = Uri.parse('auth/login');
    final $body = param;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<LoginModel, LoginModel>($request);
  }

  @override
  Future<Response<RegisterModel>> registerAPI({
    required Map<String, dynamic> param,
  }) {
    final Uri $url = Uri.parse('auth/register');
    final $body = param;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    return client.send<RegisterModel, RegisterModel>($request);
  }

  @override
  Future<Response<ProfileModel>> getMeAPI() {
    final Uri $url = Uri.parse('auth/me');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<ProfileModel, ProfileModel>($request);
  }

  @override
  Future<Response<ProfileModel>> updateProfileAPI({
    required Map<String, dynamic> param,
  }) {
    final Uri $url = Uri.parse('auth/profile');
    final $body = param;
    final Request $request = Request('PUT', $url, client.baseUrl, body: $body);
    return client.send<ProfileModel, ProfileModel>($request);
  }

  @override
  Future<Response<SubscriptionModel>> getSubscriptionAPI() {
    final Uri $url = Uri.parse('subscription');
    final Request $request = Request('GET', $url, client.baseUrl);
    return client.send<SubscriptionModel, SubscriptionModel>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> deleteAccountAPI({
    required Map<String, dynamic> param,
  }) {
    final Uri $url = Uri.parse('auth/account');
    final $body = param;
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }

  @override
  Future<Response<Map<String, dynamic>>> changePasswordAPI({
    required Map<String, dynamic> param,
  }) {
    final Uri $url = Uri.parse('auth/change-password');
    final $body = param;
    final Request $request = Request('PUT', $url, client.baseUrl, body: $body);
    return client.send<Map<String, dynamic>, Map<String, dynamic>>($request);
  }
}
