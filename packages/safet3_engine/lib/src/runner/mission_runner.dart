import 'dart:io';
import 'package:dio/dio.dart';
import 'package:puppeteer/puppeteer.dart' hide ExecutionContext;
import 'package:safet3_core/safet3_core.dart';
import 'execution_context.dart';

class MissionRunner {
  final Dio _dio = Dio();

  Future<void> run(Mission mission) async {
    final context = ExecutionContext(mission.variables);
    
    context.log('🚀 Starting Mission: ${mission.name}');

    for (final step in mission.steps) {
      try {
        await _executeStep(step, context);
      } catch (e) {
        context.log('❌ Step "${step.name}" Failed: $e');
        rethrow; 
      }
    }

    context.log('✅ Mission Completed Successfully');
  }

  Future<void> _executeStep(MissionStep step, ExecutionContext context) async {
    context.log('👉 Running step: ${step.name} (${step.type})');

    switch (step) {
      case WaitStep s:
        await Future.delayed(Duration(milliseconds: s.durationMs));
        break;

      case HttpStep s:
        await _executeHttpStep(s, context);
        break;

      case BrowserStep s: // <--- Nouveau cas géré
        await _executeBrowserStep(s, context);
        break;
    }
  }


  Future<void> _executeBrowserStep(BrowserStep step, ExecutionContext context) async {
    context.log('   Starting Chrome (User Mode)...');
    
    // Dossier temporaire pour garder la session active pendant le test
    final userDataDir = await Directory.systemTemp.createTemp('safet3_chrome_');

    final browser = await puppeteer.launch(
      headless: step.headless,
      defaultViewport: DeviceViewport(width: 1280, height: 800), // Taille standard
      userDataDir: userDataDir.path,
      args: [
        '--no-sandbox',
        '--disable-blink-features=AutomationControlled', // Cache le flag robot
        '--start-maximized'
      ],
    );

    try {
      final page = await browser.newPage();

      // STEALTH : On supprime les indices techniques que c'est un robot
      await page.evaluateOnNewDocument('''
        Object.defineProperty(navigator, 'webdriver', { get: () => undefined });
        window.navigator.chrome = { runtime: {} };
      ''');

      // User Agent récent (Windows 11 + Chrome 121)
      await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36');

      // Timeout infini (ou très long) pour te laisser le temps de cliquer si besoin
      page.defaultTimeout = Duration(minutes: 5);

      final url = context.interpolate(step.url);
      context.log('   Browsing to: $url');
      
      // On charge la page
      // waitUntil: Until.networkIdle est mieux ici pour attendre que Cloudflare finisse son script
      await page.goto(url, wait: Until.networkIdle); 

      // --- DETECTION DU CHALLENGE ---
      // On regarde si on est bloqué
      final content = await page.content ?? '';

      if (content.contains('Just a moment') || content.contains('challenge-platform')) {
        context.log('   🛡️  Cloudflare Challenge detected.');
        context.log('   👉  ACTION REQUIRED: Please solve the CAPTCHA in the browser window.');

        // ON ATTEND QUE LE CONTENU CHANGE
        // Chrome affiche le JSON brut dans une balise <pre> par défaut
        // Ou alors le texte "Just a moment" doit disparaître.
        await page.waitForFunction('''
          () => !document.body.innerText.includes("Just a moment") && 
                !document.body.innerText.includes("Verify you are human")
        ''', timeout: Duration(minutes: 5));
        
        context.log('   ✅  Challenge passed! Access granted.');
      } else {
         context.log('   ⚡️ Direct access (No challenge).');
      }

      // --- RECUPERATION DU RESULTAT (JSON) ---
      // Chrome enveloppe souvent le JSON affiché dans : <body><pre>{...}</pre></body>
      // On essaie de récupérer le texte du body.
      final bodyText = await page.evaluate('document.body.innerText');
      
      if (bodyText != null && bodyText.toString().startsWith('{')) {
         context.log('   📄  JSON Captured successfully!');
         // On peut logger un extrait
         final preview = bodyText.toString().length > 100 
             ? bodyText.toString().substring(0, 100) + '...' 
             : bodyText;
         context.log('       Data: $preview');
         
         // Sauvegarder dans le contexte pour l'utiliser plus tard si besoin
         context.set('response_body', bodyText);
      } else {
         context.log('   ⚠️  Warning: Content does not look like JSON.');
      }

    } catch (e) {
      context.log('   ❌ Browser Error: $e');
      throw e;
    } finally {
      await browser.close();
      // await userDataDir.delete(recursive: true);
    }
  }


  Future<void> _executeHttpStep(HttpStep step, ExecutionContext context) async {
    // 1. Préparation (URL, Headers...) - INCHANGÉ
    final url = context.interpolate(step.url);
    final headers = <String, dynamic>{};
    step.headers?.forEach((k, v) => headers[k] = context.interpolate(v));

    final options = Options(
      method: step.method.toString().split('.').last.toUpperCase(),
      headers: headers,
      validateStatus: (status) => true,
    );

    // 2. Requête - INCHANGÉ
    final response = await _dio.request(
        url,
        data: step.body, // Penser à interpoler le body plus tard
        options: options
    );

    context.log('   Response Status: ${response.statusCode}');

    // 3. Assertion - INCHANGÉ
    if (step.assertSuccess && (response.statusCode == null || response.statusCode! >= 400)) {
      throw Exception('HTTP Error ${response.statusCode}');
    }

    // 4. EXTRACTION (NOUVEAU)
    if (step.extract != null && step.extract!.isNotEmpty) {
      _processExtraction(response.data, step.extract!, context);
    }
  }

  /// Extrait les valeurs du JSON et les met dans le Context
  void _processExtraction(dynamic responseData, List<ExtractionConfig> configs, ExecutionContext context) {
    for (final config in configs) {
      try {
        final value = _resolvePath(responseData, config.source);
        context.set(config.target, value);
        context.log('   💾 Extracted: ${config.target} = $value');
      } catch (e) {
        context.log('   ⚠️ Failed to extract "${config.source}": $e');
      }
    }
  }

  /// Parcours le JSON pour trouver la valeur (Supporte "users[0].id" et "[0].name")
  dynamic _resolvePath(dynamic data, String path) {
    var current = data;
    
    // On nettoie le chemin : "users[0].id" -> "users.[0].id" pour simplifier le split
    // Regex pour mettre un point avant chaque crochet ouvrant [
    final normalizedPath = path.replaceAll('[', '.[');
    final segments = normalizedPath.split('.').where((s) => s.isNotEmpty).toList();

    for (var segment in segments) {
      if (current == null) return null;

      // Cas 1 : C'est un index de liste "[0]"
      if (segment.startsWith('[') && segment.endsWith(']')) {
        if (current is! List) throw Exception('Expected List but got ${current.runtimeType}');
        
        final indexStr = segment.substring(1, segment.length - 1); // Enlève [ et ]
        final index = int.parse(indexStr);
        
        if (index < 0 || index >= current.length) throw Exception('Index out of bounds: $index');
        current = current[index];
      } 
      // Cas 2 : C'est une clé de map "id"
      else {
        if (current is! Map) throw Exception('Expected Map but got ${current.runtimeType}');
        current = current[segment];
      }
    }
    return current;
  }

}