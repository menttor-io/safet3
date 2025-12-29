// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$MissionStepToJson(MissionStep instance) =>
    <String, dynamic>{
      'stringify': instance.stringify,
      'hashCode': instance.hashCode,
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'props': instance.props,
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
  extract: (json['extract'] as List<dynamic>?)
      ?.map((e) => ExtractionConfig.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$HttpStepToJson(HttpStep instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'method': _$HttpMethodEnumMap[instance.method]!,
  'url': instance.url,
  'headers': instance.headers,
  'body': instance.body,
  'assertSuccess': instance.assertSuccess,
  'extract': instance.extract?.map((e) => e.toJson()).toList(),
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

BrowserStep _$BrowserStepFromJson(Map<String, dynamic> json) => BrowserStep(
  id: json['id'] as String,
  name: json['name'] as String,
  url: json['url'] as String,
  waitForSelector: json['waitForSelector'] as String?,
  headless: json['headless'] as bool? ?? true,
  extractCookies: json['extractCookies'] as bool? ?? false,
  userAgent: json['userAgent'] as String?,
);

Map<String, dynamic> _$BrowserStepToJson(BrowserStep instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'waitForSelector': instance.waitForSelector,
      'headless': instance.headless,
      'extractCookies': instance.extractCookies,
      'userAgent': instance.userAgent,
    };

ExtractionConfig _$ExtractionConfigFromJson(Map<String, dynamic> json) =>
    ExtractionConfig(
      source: json['source'] as String,
      target: json['target'] as String,
    );

Map<String, dynamic> _$ExtractionConfigToJson(ExtractionConfig instance) =>
    <String, dynamic>{'source': instance.source, 'target': instance.target};
