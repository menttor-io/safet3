import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'http_method.dart';

part 'mission_step.g.dart';

@JsonSerializable(createFactory: false)
sealed class MissionStep extends Equatable {
  final String id;
  final String name;
  final String type;

  const MissionStep({required this.id, required this.name, required this.type});

  factory MissionStep.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'http':
        return HttpStep.fromJson(json);
      case 'wait':
        return WaitStep.fromJson(json);
      case 'browser':
        return BrowserStep.fromJson(json);
      default:
        throw FormatException('Unknown step type: $type');
    }
  }

  Map<String, dynamic> toJson();
  @override
  List<Object?> get props => [id, name, type];
}

/// --- HTTP STEP ---
@JsonSerializable(explicitToJson: true)
class HttpStep extends MissionStep {
  final HttpMethod method;
  final String url;
  final Map<String, String>? headers;
  final Map<String, dynamic>? body;
  final bool assertSuccess;
  
  /// Configuration pour extraire des variables de la réponse JSON
  final List<ExtractionConfig>? extract; // <--- NOUVEAU

  const HttpStep({
    required String id,
    required String name,
    required this.method,
    required this.url,
    this.headers,
    this.body,
    this.assertSuccess = true,
    this.extract,
  }) : super(id: id, name: name, type: 'http');

  factory HttpStep.fromJson(Map<String, dynamic> json) => _$HttpStepFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$HttpStepToJson(this);
  @override
  List<Object?> get props => [...super.props, method, url, headers, body, assertSuccess, extract];
}

/// --- WAIT STEP ---
@JsonSerializable()
class WaitStep extends MissionStep {
  final int durationMs;
  const WaitStep({required String id, required String name, required this.durationMs}) : super(id: id, name: name, type: 'wait');
  factory WaitStep.fromJson(Map<String, dynamic> json) => _$WaitStepFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$WaitStepToJson(this);
  @override
  List<Object?> get props => [...super.props, durationMs];
}

/// --- BROWSER STEP ---
@JsonSerializable(explicitToJson: true)
class BrowserStep extends MissionStep {
  final String url;
  final String? waitForSelector;
  final bool headless;
  final bool extractCookies;
  final String? userAgent;
  const BrowserStep({required String id, required String name, required this.url, this.waitForSelector, this.headless = true, this.extractCookies = false, this.userAgent}) : super(id: id, name: name, type: 'browser');
  factory BrowserStep.fromJson(Map<String, dynamic> json) => _$BrowserStepFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$BrowserStepToJson(this);
  @override
  List<Object?> get props => [...super.props, url, waitForSelector, headless, extractCookies, userAgent];
}

/// --- EXTRACTION CONFIG (NOUVEAU) ---
@JsonSerializable()
class ExtractionConfig extends Equatable {
  /// Chemin JSON (ex: "users[0].id" ou "token")
  final String source;
  /// Nom de la variable où stocker la valeur
  final String target;

  const ExtractionConfig({required this.source, required this.target});

  factory ExtractionConfig.fromJson(Map<String, dynamic> json) => _$ExtractionConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ExtractionConfigToJson(this);
  @override
  List<Object?> get props => [source, target];
}