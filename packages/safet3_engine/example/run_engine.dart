import 'dart:io';
import 'package:safet3_engine/safet3_engine.dart';

void main() async {
  final parser = MissionParser();
  final runner = MissionRunner();
  final file = File('example/test_mission.yaml');

  try {
    print('--- 1. Parsing ---');
    final mission = await parser.parseFile(file);
    
    print('--- 2. Execution ---');
    await runner.run(mission);
    
  } catch (e) {
    print('🔥 Critical Failure: $e');
  }
}