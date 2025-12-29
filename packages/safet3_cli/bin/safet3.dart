import 'dart:io';
import 'package:args/args.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:safet3_engine/safet3_engine.dart';
import 'package:safet3_core/safet3_core.dart';

void main(List<String> arguments) async {
  final logger = Logger();

  // 1. Définition des arguments
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Print this usage information.')
    ..addOption('file', abbr: 'f', help: 'Path to the mission YAML file.');

  try {
    final results = parser.parse(arguments);

    // Affichage de l'aide
    if (results['help'] == true) {
      _printUsage(logger, parser);
      return;
    }

    // Commande "run" (ex: safet3 run -f test.yaml)
    if (results.rest.isNotEmpty && results.rest.first == 'run') {
      await _runCommand(results, logger);
    } else {
      logger.err('Unknown command. Use "safet3 run -f <file>"');
      _printUsage(logger, parser);
      exit(ExitCode.usage.code);
    }

  } catch (e) {
    logger.err(e.toString());
    exit(ExitCode.usage.code);
  }
}

Future<void> _runCommand(ArgResults args, Logger logger) async {
  final filePath = args['file'] as String?;
  
  if (filePath == null) {
    logger.err('❌ Missing required argument: --file (or -f)');
    exit(ExitCode.usage.code);
  }

  final file = File(filePath);
  if (!file.existsSync()) {
    logger.err('❌ File not found: $filePath');
    exit(ExitCode.ioError.code);
  }

  // Joli spinner de chargement
  final progress = logger.progress('Parsing mission file...');
  
  try {
    // A. Parsing
    final engineParser = MissionParser();
    final mission = await engineParser.parseFile(file);
    progress.complete('Mission "${mission.name}" loaded successfully.');

    // B. Execution
    logger.info('\n🚀 Executing Mission ID: ${mission.id}');
    logger.info('----------------------------------------');

    final runner = MissionRunner();
    // TODO: Connecter le logger du Context au logger Mason pour avoir les couleurs
    await runner.run(mission);

    logger.success('\n✅ Mission Completed without critical errors.');
    exit(ExitCode.success.code);

  } catch (e) {
    progress.fail('Execution failed');
    logger.err('🔥 Error: $e');
    exit(ExitCode.software.code);
  }
}

void _printUsage(Logger logger, ArgParser parser) {
  logger.info('Safet3 CLI - API Testing & Security Tool');
  logger.info('\nUsage: safet3 <command> [arguments]');
  logger.info('\nCommands:');
  logger.info('  run    Execute a mission file');
  logger.info('\nOptions:');
  logger.info(parser.usage);
}