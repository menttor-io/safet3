import 'dart:convert';
import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:safet3_core/safet3_core.dart';

/// Responsible for reading mission files and converting them into Objects.
class MissionParser {

  /// Parses a Mission from a YAML string content.
  Mission parseYaml(String yamlContent) {
    try {
      // 1. Load YAML structure
      final yamlNode = loadYaml(yamlContent);

      // 2. Normalize: Convert YamlMap/YamlList to standard Dart Map/List
      // The easiest robust way is to encode to JSON string and decode back.
      // This strips away the specific 'YamlMap' types that crash fromJson.
      final jsonString = jsonEncode(yamlNode);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      // 3. Convert to strongly typed Mission object
      return Mission.fromJson(jsonMap);
    } catch (e, stackTrace) {
      throw FormatException(
        'Failed to parse mission YAML: $e',
        yamlContent,
        0, // We could improve offset calculation later
      );
    }
  }

  /// Convenience method to parse directly from a File.
  Future<Mission> parseFile(File file) async {
    if (!await file.exists()) {
      throw PathNotFoundException(file.path, const OSError(), 'Mission file not found');
    }
    final content = await file.readAsString();
    return parseYaml(content);
  }
}