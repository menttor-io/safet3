// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mission _$MissionFromJson(Map<String, dynamic> json) => Mission(
  id: json['id'] as String,
  name: json['name'] as String,
  steps: (json['steps'] as List<dynamic>)
      .map((e) => MissionStep.fromJson(e as Map<String, dynamic>))
      .toList(),
  variables: (json['variables'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
);

Map<String, dynamic> _$MissionToJson(Mission instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'steps': instance.steps.map((e) => e.toJson()).toList(),
  'variables': instance.variables,
};
