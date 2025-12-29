import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'http_method.dart';

part 'mission_step.g.dart';

/// Base class for any step within a Mission.
/// Uses Dart 3 sealed class pattern for exhaustive switch handling.
@JsonSerializable(explicitToJson: true)
sealed class MissionStep extends Equatable {
  /// Unique identifier for this step.
  final String id;

  /// Human-readable name for reporting.
  final String name;

  /// The type discriminator for JSON serialization.
  final String type;

  const MissionStep({
    required this.id,
    required this.name,
    required this.type,
  });

  /// Factory constructor for polymorphism logic.
  factory MissionStep.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'http':
        return HttpStep.fromJson(json);
      case 'wait':
        return WaitStep.fromJson(json);
      default:
        throw FormatException('Unknown step type: $type');
    }
  }

  Map<String, dynamic> toJson();
  
  @override
  List<Object?> get props => [id, name, type];
}

/// Represents a standard HTTP request step (Feature/Load testing).
@JsonSerializable(explicitToJson: true)
class HttpStep extends MissionStep {
  final HttpMethod method;
  final String url;
  final Map<String, String>? headers;
  final Map<String, dynamic>? body;

  /// If true, we expect this request to succeed (2xx).
  final bool assertSuccess;

  const HttpStep({
    required String id,
    required String name,
    required this.method,
    required this.url,
    this.headers,
    this.body,
    this.assertSuccess = true,
  }) : super(id: id, name: name, type: 'http');

  factory HttpStep.fromJson(Map<String, dynamic> json) =>
      _$HttpStepFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HttpStepToJson(this);

  @override
  List<Object?> get props => [...super.props, method, url, headers, body];
}

/// Represents a pause/delay in the workflow.
@JsonSerializable()
class WaitStep extends MissionStep {
  /// Duration in milliseconds.
  final int durationMs;

  const WaitStep({
    required String id,
    required String name,
    required this.durationMs,
  }) : super(id: id, name: name, type: 'wait');

  factory WaitStep.fromJson(Map<String, dynamic> json) =>
      _$WaitStepFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WaitStepToJson(this);

  @override
  List<Object?> get props => [...super.props, durationMs];
}