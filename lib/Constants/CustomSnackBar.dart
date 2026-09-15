
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:ottapp/Const/AppColors.dart';
import 'package:ottapp/Widgets/ApptextWidget.dart';
import 'package:ottapp/Models/GeneralErrorModel.dart';

///Custom SnackBar
class Utility {
  static void showSnackBar(String? msg, {bool isError = false, dynamic response}) {
    String? displayText = msg;

    if (response != null) {
      final extractedMsg = _extractMessage(response);
      if (extractedMsg != null && extractedMsg.isNotEmpty) {
        displayText = extractedMsg;
      }
    }

    displayText = _cleanMessage(displayText);

    Get.showSnackbar(
      GetSnackBar(
        maxWidth: 400.w,
        borderRadius: 12.r,
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        snackPosition: SnackPosition.TOP,
        snackStyle: SnackStyle.FLOATING,
        backgroundColor: const Color(0xFF1E1E1E), // Dark grey
        borderColor: AppColors.white10,
        borderWidth: 1,
        boxShadows: [
          BoxShadow(
            color: Colors.black.withAlpha(102),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        icon: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: (isError ? Colors.red : AppColors.appColors).withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
            color: isError ? Colors.redAccent : AppColors.appColors,
            size: 20.sp,
          ),
        ),
        messageText: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: AppTextWidget(
            text: displayText ?? '',
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            maxLines: 3,
          ),
        ),
        duration: const Duration(seconds: 3),
        dismissDirection: DismissDirection.horizontal,
        forwardAnimationCurve: Curves.easeOutCirc,
      ),
    );
  }

  static String? _extractMessage(dynamic response) {
    if (response == null) return null;
    String? message;

    if (response is chopper.Response) {
      if (response.isSuccessful) {
        final body = response.body;
        if (body != null) {
          if (body is Map) {
            message = _extractFromMap(body);
          } else {
            try {
              final msg = (body as dynamic).message;
              if (msg != null) message = msg.toString();
            } catch (_) {}
          }
        }
      } else {
        final error = response.error;
        if (error != null) {
          if (error is GeneralErrorModel) {
            if (error.message != null && error.message!.isNotEmpty) {
              message = error.message;
            }
          } else if (error is Map) {
            message = _extractFromMap(error);
          } else if (error is String) {
            if (error.isNotEmpty) message = error;
          } else {
            try {
              final msg = (error as dynamic).message;
              if (msg != null) message = msg.toString();
            } catch (_) {}
          }
        }

        if (message == null || message.isEmpty) {
          final bodyStr = response.bodyString;
          if (bodyStr.isNotEmpty) {
            try {
              final decoded = jsonDecode(bodyStr);
              if (decoded is Map) {
                message = _extractFromMap(decoded);
              }
            } catch (_) {}
          }
        }
      }
    } else if (response is Exception || response is Error) {
      try {
        final msg = (response as dynamic).message;
        if (msg != null && msg.toString().isNotEmpty) {
          message = msg.toString();
        }
      } catch (_) {}

      if (message == null) {
        final str = response.toString();
        if (str.startsWith("Exception: ")) {
          message = str.substring("Exception: ".length);
        } else {
          message = str;
        }
      }
    } else if (response is String) {
      if (response.isNotEmpty) message = response;
    }

    return message;
  }

  static String? _cleanMessage(String? raw) {
    if (raw == null) return null;
    String text = raw.trim();
    if (text.isEmpty) return text;

    // Strip "Exception: " if present
    if (text.startsWith('Exception: ')) {
      text = text.substring('Exception: '.length).trim();
    }

    // Check if HTML error page
    if (_isHtml(text)) {
      return 'Something went wrong. Please try again.';
    }

    // Try extracting JSON message if it looks like JSON or contains JSON
    final parsed = _tryExtractJsonMessage(text);
    if (parsed != null && parsed.isNotEmpty) {
      return _cleanMessage(parsed);
    }

    return text;
  }

  static String? _tryExtractJsonMessage(String text) {
    // 1. Direct JSON map or list
    if ((text.startsWith('{') && text.endsWith('}')) ||
        (text.startsWith('[') && text.endsWith(']'))) {
      try {
        final decoded = jsonDecode(text);
        if (decoded is Map) {
          return _extractFromMap(decoded);
        } else if (decoded is List && decoded.isNotEmpty) {
          final first = decoded.first;
          if (first is Map) return _extractFromMap(first);
          return first.toString();
        }
      } catch (_) {}
    }

    // 2. Embedded JSON substring e.g. "Error: {"success":false,"message":"..."}"
    final int startIdx = text.indexOf('{');
    final int endIdx = text.lastIndexOf('}');
    if (startIdx != -1 && endIdx > startIdx) {
      try {
        final substring = text.substring(startIdx, endIdx + 1);
        final decoded = jsonDecode(substring);
        if (decoded is Map) {
          return _extractFromMap(decoded);
        }
      } catch (_) {}
    }

    return null;
  }

  static String? _extractFromMap(Map decoded) {
    // 1. Check 'message' or 'msg'
    final dynamic msg = decoded['message'] ?? decoded['msg'];
    if (msg is String && msg.isNotEmpty) return msg;
    if (msg is List && msg.isNotEmpty) return msg.first.toString();
    if (msg is Map && msg.isNotEmpty) {
      final sub = _extractFromMap(msg);
      if (sub != null) return sub;
    }

    // 2. Check 'error'
    final dynamic err = decoded['error'];
    if (err is String && err.isNotEmpty) return err;
    if (err is List && err.isNotEmpty) return err.first.toString();
    if (err is Map && err.isNotEmpty) {
      final sub = _extractFromMap(err);
      if (sub != null) return sub;
    }

    // 3. Check validation 'errors'
    final dynamic errors = decoded['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final firstVal = errors.values.first;
      if (firstVal is List && firstVal.isNotEmpty) {
        return firstVal.first.toString();
      }
      return firstVal.toString();
    }
    if (errors is List && errors.isNotEmpty) {
      final firstVal = errors.first;
      if (firstVal is Map) return _extractFromMap(firstVal);
      return firstVal.toString();
    }
    if (errors is String && errors.isNotEmpty) {
      return errors;
    }

    // 4. Check 'detail' or 'description'
    final dynamic detail = decoded['detail'] ?? decoded['description'];
    if (detail is String && detail.isNotEmpty) return detail;

    return null;
  }

  static bool _isHtml(String str) {
    final trimmed = str.trim().toLowerCase();
    return trimmed.startsWith('<!doctype') ||
        trimmed.startsWith('<html') ||
        trimmed.contains('<html') ||
        trimmed.contains('</html>') ||
        trimmed.contains('<body') ||
        trimmed.contains('</body>');
  }
}


