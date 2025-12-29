import 'package:json_annotation/json_annotation.dart';

/// Supported HTTP methods for safet3 missions.
enum HttpMethod {
  @JsonValue('GET')
  get,
  @JsonValue('POST')
  post,
  @JsonValue('PUT')
  put,
  @JsonValue('DELETE')
  delete,
  @JsonValue('PATCH')
  patch,
}