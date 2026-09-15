import 'dart:async';
import 'dart:convert';
import 'package:chopper/chopper.dart';
import 'package:ottapp/Models/GeneralErrorModel.dart';



typedef JsonConvertorFunction = dynamic Function(Map<String, dynamic>);

class JsonToTypeConverter extends JsonConverter implements ErrorConverter {
  final Map<Type, JsonConvertorFunction> jsonConvertorMap;
  const JsonToTypeConverter({required this.jsonConvertorMap});

  // converts data from api to model based on type
  dynamic decode<BodyType, InnerType>(dynamic entity) {
    if (entity == null) return null;

    // If the caller asked for dynamic/object (or a raw json structure), return as-is.
    if (BodyType == dynamic ||
        BodyType == Object ||
        BodyType == Map ||
        BodyType == List) {
      return entity;
    }

    if (entity is List) return _decodeList<BodyType, InnerType>(entity);
    if (entity is Map<String, dynamic>) {
      return _decodeMap<BodyType, InnerType>(entity);
    }

    return entity;
  }

  // decodes map to Model
  BodyType _decodeMap<BodyType, InnerType>(Map<String, dynamic> entity) {
    if (!jsonConvertorMap.containsKey(BodyType)) {
      // If no fromJson exists, fall back to returning the raw map if assignable.
      return entity as BodyType;
    }
    return jsonConvertorMap[BodyType]!(entity) as BodyType;
  }

  // decodees lsit of Map to List of model
  List<InnerType> _decodeList<BodyType, InnerType>(List entity) {
    // when we want a List<Model> then our BodyType will be List, therefore we are passing InnerType in place of BodyType
    if (InnerType == dynamic || InnerType == Object) {
      return entity.cast<InnerType>();
    }
    return List.generate(
      entity.length,
      (index) => _decodeMap<InnerType, InnerType>(
        (entity[index] as Map).cast<String, dynamic>(),
      ),
    );
  }

  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(Response response) {
    // BodyType: Type of model we want are respinse to be converted.

    // InnerType is type of model we want to convert our response from api when we are getting List of Map<String,dynamic>,
    // so in this case our BodyType will be List

    final dynamic raw = response.body;
    final dynamic decoded = raw is String ? json.decode(raw) : raw;
    return response.copyWith(body: decode<BodyType, InnerType>(decoded));
  }

  @override
  FutureOr<Response> convertError<BodyType, InnerType>(Response response) {
    final dynamic raw = response.body;
    dynamic decoded = raw;

    if (raw is String) {
      try {
        decoded = json.decode(raw);
      } catch (_) {
        decoded = raw;
      }
    }

    if (decoded is Map) {
      return response.copyWith(
        bodyError: decode<GeneralErrorModel, GeneralErrorModel>(
          decoded.cast<String, dynamic>(),
        ),
      );
    }

    if (decoded is String) {
      return response.copyWith(
        bodyError: decode<GeneralErrorModel, GeneralErrorModel>({
          "status": response.statusCode,
          "message": decoded,
          "data": null,
        }),
      );
    }

    return response.copyWith(
      bodyError: decode<GeneralErrorModel, GeneralErrorModel>({
        "status": response.statusCode,
        "message": "Unknown error",
        "data": decoded?.toString(),
      }),
    );
  }
}

// Exception class for Data class that does not have fromJson method implementation
class FromJsonMethodNotFound implements Exception {
  final String type;
  final String message = "fromJson() method not implemented";

  @override
  String toString() => "$type: $message";
  FromJsonMethodNotFound({required this.type});
}
