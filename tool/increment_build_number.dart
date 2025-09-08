import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

void main() {
  final File pubspecFile = File('pubspec.yaml');
  final String pubspecContent = pubspecFile.readAsStringSync();
  final YamlEditor yamlEditor = YamlEditor(pubspecContent);

  final String? currentVersion = yamlEditor.parse(pubspecContent)['version']?.toString();

  if (currentVersion == null) {
    print('Error: "version" not found in pubspec.yaml');
    exit(1);
  }

  final List<String> parts = currentVersion.split('+');
  final String semVer = parts[0];
  int buildNumber = 0;

  if (parts.length > 1) {
    buildNumber = int.tryParse(parts[1]) ?? 0;
  }

  buildNumber++;
  final String newVersion = '\$semVer+\$buildNumber';

  yamlEditor.update(['version'], newVersion);
  pubspecFile.writeAsStringSync(yamlEditor.toString());

  print('Build number incremented to: \$newVersion');
}
