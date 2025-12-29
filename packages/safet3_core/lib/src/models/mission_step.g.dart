// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MissionStep _$MissionStepFromJson(Map<String, dynamic> json) => MissionStep(
  id: json['id'] as String,
  name: json['name'] as String,
  type: json['type'] as String,
);

Map<String, dynamic> _$MissionStepToJson(MissionStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
    };

HttpStep _$HttpStepFromJson(Map<String, dynamic> json) => HttpStep(
  id: json['id'] as String,
  name: json['name'] as String,
  method: $enumDecode(_$HttpMethodEnumMap, json['method']),
  url: json['url'] as String,
  headers: (json['headers'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  body: json['body'] as Map<String, dynamic>?,
  assertSuccess: json['assertSuccess'] as bool? ?? true,
);

Map<String, dynamic> _$HttpStepToJson(HttpStep instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'method': _$HttpMethodEnumMap[instance.method]!,
  'url': instance.url,
  'headers': instance.headers,
  'body': instance.body,
  'assertSuccess': instance.assertSuccess,
};

const _$HttpMethodEnumMap = {
  HttpMethod.get: 'GET',
  HttpMethod.post: 'POST',
  HttpMethod.put: 'PUT',
  HttpMethod.delete: 'DELETE',
  HttpMethod.patch: 'PATCH',
};

WaitStep _$WaitStepFromJson(Map<String, dynamic> json) => WaitStep(
  id: json['id'] as String,
  name: json['name'] as String,
  durationMs: (json['durationMs'] as num).toInt(),
);

Map<String, dynamic> _$WaitStepToJson(WaitStep instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'durationMs': instance.durationMs,
};
