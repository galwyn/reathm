import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

void main(List<String> arguments) {
  if (arguments.isEmpty || (arguments[0] != 'major' && arguments[0] != 'minor' && arguments[0] != 'patch')) {
    print('Usage: dart tool/increment_version.dart [major|minor|patch]');
    exit(1);
  }

  final String incrementType = arguments[0];

  final File pubspecFile = File('pubspec.yaml');
  final String pubspecContent = pubspecFile.readAsStringSync();
  final YamlEditor yamlEditor = YamlEditor(pubspecContent);

  final String? currentVersion = (loadYaml(pubspecContent) as YamlMap)['version']?.toString();

  if (currentVersion == null) {
    print('Error: "version" not found in pubspec.yaml');
    exit(1);
  }

  final List<String> parts = currentVersion.split('+');
  final List<int> semVerParts = parts[0].split('.').map(int.parse).toList();

  if (semVerParts.length != 3) {
    print('Error: Invalid semantic version format. Expected MAJOR.MINOR.PATCH');
    exit(1);
  }

  int major = semVerParts[0];
  int minor = semVerParts[1];
  int patch = semVerParts[2];

  switch (incrementType) {
    case 'major':
      major++;
      minor = 0;
      patch = 0;
    case 'minor':
      minor++;
      patch = 0;
    case 'patch':
      patch++;
  }

  final String newSemVer = '$major.$minor.$patch';
  final String newVersion = '$newSemVer+0'; // Reset build number

  yamlEditor.update(['version'], newVersion);
  pubspecFile.writeAsStringSync(yamlEditor.toString());

  print('Version incremented to: $newVersion');
}
