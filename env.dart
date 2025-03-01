import 'dart:io';
import 'package:dotenv/dotenv.dart';

void main() {
  // Load .env file
  final env = DotEnv()..load();

  final directory = Directory('lib/config');
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  // Start building the config class content
  final StringBuffer config = StringBuffer();
  config.writeln('class AppConfig {');
  config.writeln('  const AppConfig._();\n');

  // Generate static constants for each environment variable
  // ignore: invalid_use_of_visible_for_testing_member
  env.map.forEach((key, value) {
    final camelKey = _convertToCamelCase(key);
    config.writeln('  static const String $camelKey = \'$value\';');
  });

  config.writeln('}');

  // Write to app_config.dart file
  File('lib/config/app_config.dart').writeAsStringSync(config.toString());
}

// Helper method to convert ENV_VAR format to camelCase
String _convertToCamelCase(String envVar) {
  final words = envVar.toLowerCase().split('_');
  return words.first +
      words
          .skip(1)
          .map(
            (word) =>
                word.substring(0, 1).toUpperCase() +
                word.substring(1).toLowerCase(),
          )
          .join('');
}
