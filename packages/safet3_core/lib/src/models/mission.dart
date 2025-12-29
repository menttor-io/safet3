import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'mission_step.dart';

part 'mission.g.dart';

/// The root object representing a full testing scenario.
@JsonSerializable(explicitToJson: true)
class Mission extends Equatable {
  /// Unique ID for the mission run.
  final String id;

  /// Project or Test name.
  final String name;

  /// List of steps to execute sequentially or logically.
  final List<MissionStep> steps;

  /// Global variables (e.g., {{baseUrl}})
  final Map<String, String>? variables;

  const Mission({
    required this.id,
    required this.name,
    required this.steps,
    this.variables,
  });

  factory Mission.fromJson(Map<String, dynamic> json) =>
      _$MissionFromJson(json);

  Map<String, dynamic> toJson() => _$MissionToJson(this);

  @override
  List<Object?> get props => [id, name, steps, variables];
}