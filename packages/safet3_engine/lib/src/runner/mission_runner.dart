import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:safet3_core/safet3_core.dart';
import 'execution_context.dart';

class MissionRunner {
  final Dio _dio = Dio();

  /// Executes a mission from start to finish.
  Future<void> run(Mission mission) async {
    final context = ExecutionContext(mission.variables);
    
    context.log('🚀 Starting Mission: ${mission.name}');

    for (final step in mission.steps) {
      try {
        await _executeStep(step, context);
      } catch (e) {
        context.log('❌ Step "${step.name}" Failed: $e');
        // Selon la config, on pourrait arrêter la mission ici (Fail Fast)
        rethrow; 
      }
    }

    context.log('✅ Mission Completed Successfully');
  }

  Future<void> _executeStep(MissionStep step, ExecutionContext context) async {
    context.log('👉 Running step: ${step.name} (${step.type})');

    // Pattern Matching sur le type de Step (Dart 3)
    switch (step) {
      case WaitStep s:
        await Future.delayed(Duration(milliseconds: s.durationMs));
        break;

      case HttpStep s:
        await _executeHttpStep(s, context);
        break;
        
      // Pas de default grâce au sealed class (Exhaustive check)
    }
  }

  Future<void> _executeHttpStep(HttpStep step, ExecutionContext context) async {
    // 1. Interpolation des variables (URL, Headers, Body)
    final url = context.interpolate(step.url);
    
    final headers = <String, dynamic>{};

    final mergedHeaders = <String, dynamic>{
      'User-Agent': 'Safet3Runtime/1.0', // <-- L'identité de ton outil
      'Accept': 'application/json',
    };

    step.headers?.forEach((k, v) {
      headers[k] = context.interpolate(v);
    });

    if (headers.isNotEmpty) {
      mergedHeaders.addAll(headers);
    }

    // 2. Préparation de la requête
    final options = Options(
      method: step.method.toString().split('.').last.toUpperCase(), // HttpMethod.get -> GET
      headers: mergedHeaders,
      validateStatus: (status) => true, // On gère les erreurs nous-mêmes
    );

    // 3. Exécution avec Dio
    final response = await _dio.request(
      url,
      data: step.body, // TODO: Interpoler le body si c'est une string
      options: options,
    );

    context.log('   Create Request ${options.method} $url -> Status ${response.statusCode}');

    // 4. Assertion (Vérification simple)
    if (step.assertSuccess && (response.statusCode == null || response.statusCode! >= 400)) {
      throw Exception('Assertion Failed: Expected 2xx/3xx but got ${response.statusCode}');
    }

    // 5. Extraction de données (ex: Token)
    // Pour l'instant on simule l'extraction si besoin. 
    // Dans la prochaine version, on ajoutera le champ `extract` au modèle YAML.
    if (response.data is Map<String, dynamic>) {
       // Exemple simple: si la réponse contient "token", on le garde automatiquement
       // Ceci sera remplacé par une logique précise définie dans le YAML plus tard.
       final data = response.data as Map<String, dynamic>;
       if (data.containsKey('token')) {
         context.set('token', data['token']);
         context.log('   💾 Extracted variable: token = ${data['token']}');
       }
    }
  }
}