import 'dart:io';
import 'package:safet3_engine/safet3_engine.dart';

void main() async {
  print('--- Safet3 Parser Test ---');
  
  final parser = MissionParser();
  final file = File('example/test_mission.yaml');

  try {
    print('Reading file: ${file.path}...');
    final mission = await parser.parseFile(file);
    
    print('✅ Success! Parsed Mission: "${mission.name}" (ID: ${mission.id})');
    print('📊 Total Steps: ${mission.steps.length}');
    
    for (final step in mission.steps) {
      print('   - [${step.type}] ${step.name} (ID: ${step.id})');
    }
    
  } catch (e) {
    print('❌ Error: $e');
  }
}