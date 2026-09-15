class GeneralErrorModel {
  int? code;
  String? errorCode;
  String? message;
  String? msgHeader;
  String? msgDesc;
  String? msgBtn;
  dynamic data;

  GeneralErrorModel({
    this.message,
    this.code,
    this.errorCode,
    this.msgHeader,
    this.msgDesc,
    this.msgBtn,
    this.data,
  });

  factory GeneralErrorModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GeneralErrorModel();

    String? message;
    final dynamic rawMsg = json['message'] ?? json['msg'] ?? json['error'];

    if (rawMsg is String) {
      message = rawMsg;
    } else if (rawMsg is List && rawMsg.isNotEmpty) {
      message = rawMsg.first.toString();
    } else if (rawMsg is Map && rawMsg.isNotEmpty) {
      final sub = rawMsg['message'] ?? rawMsg['msg'] ?? rawMsg.values.first;
      message = sub?.toString();
    }

    if (message == null && json['errors'] != null) {
      final errors = json['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstVal = errors.values.first;
        if (firstVal is List && firstVal.isNotEmpty) {
          message = firstVal.first.toString();
        } else {
          message = firstVal.toString();
        }
      } else if (errors is List && errors.isNotEmpty) {
        message = errors.first.toString();
      } else if (errors is String) {
        message = errors;
      }
    }

    int? code;
    String? errorCode;
    if (json['status'] is int) {
      code = json['status'];
    } else if (json['code'] is int) {
      code = json['code'];
    } else if (json['code'] is String) {
      errorCode = json['code'];
    }
    if (json['error_code'] is String) {
      errorCode = json['error_code'];
    }

    final msgHeader = json['msg_header']?.toString();
    final msgDesc = json['msg_desc']?.toString();
    final msgBtn = json['msg_btn']?.toString();

    return GeneralErrorModel(
      code: code,
      errorCode: errorCode,
      message: message,
      msgHeader: msgHeader,
      msgDesc: msgDesc,
      msgBtn: msgBtn,
      data: json['data']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'status': code,
      'error_code': errorCode,
      'message': message,
      'msg_header': msgHeader,
      'msg_desc': msgDesc,
      'msg_btn': msgBtn,
      'data': data,
    };
  }
}
