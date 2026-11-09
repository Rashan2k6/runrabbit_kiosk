import 'dart:io';

/// Reads `lib/app/strings.dart` and exports all UI and parameterized strings
/// to `tools/strings.csv` with columns: key, english, sinhala, reviewed.
void main() {
  final root = Directory.current;
  final stringsFile = File('${root.path}/lib/app/strings.dart');
  final csvFile = File('${root.path}/tools/strings.csv');

  if (!stringsFile.existsSync()) {
    stderr.writeln('Cannot find strings.dart at ${stringsFile.path}');
    exit(1);
  }

  final content = stringsFile.readAsStringSync();
  final enEntries = _parseDartMap(content, '_en');
  final siEntries = _parseDartMap(content, '_si');

  final buffer = StringBuffer();
  buffer.writeln('key,english,sinhala,reviewed');

  for (final entry in enEntries.entries) {
    final key = entry.key;
    final enText = entry.value.value;
    final siInfo = siEntries[key];
    final siText = siInfo?.value ?? '';
    final reviewed = (siInfo != null && siInfo.reviewed) ? 'yes' : 'no';

    buffer.writeln(
      '${_escapeCsv(key)},${_escapeCsv(enText)},${_escapeCsv(siText)},$reviewed',
    );
  }

  csvFile.writeAsStringSync(buffer.toString());
  stdout.writeln('Exported ${enEntries.length} string entries to ${csvFile.path}');
}

class _StringEntry {
  _StringEntry({required this.value, required this.reviewed});
  final String value;
  final bool reviewed;
}

Map<String, _StringEntry> _parseDartMap(String source, String mapName) {
  final mapRegex = RegExp(
    'const\\s+$mapName\\s*=\\s*<String,\\s*String>\\s*\\{(.*?)\\};',
    dotAll: true,
  );
  final match = mapRegex.firstMatch(source);
  if (match == null) {
    throw FormatException('Could not find map $mapName in source');
  }

  final block = match.group(1)!;
  final entryRegex = RegExp(
    r'''((?:\s*//[^\n]*\n)*)\s*['"]([^'"]+)['"]\s*:\s*((?:(?:'[^'\\]*(?:\\.[^'\\]*)*'|"[^"\\]*(?:\\.[^"\\]*)*")\s*)+)\s*,\s*(//[^\n]*)?''',
    multiLine: true,
  );
  final strTokenRegex = RegExp(
    r'''(?:'([^'\\]*(?:\\.[^'\\]*)*)'|"([^"\\]*(?:\\.[^"\\]*)*)")''',
  );

  final result = <String, _StringEntry>{};

  for (final m in entryRegex.allMatches(block)) {
    final commentBefore = m.group(1) ?? '';
    final key = m.group(2)!;
    final valRaw = m.group(3)!;
    final commentInline = m.group(4) ?? '';

    final valParts = <String>[];
    for (final token in strTokenRegex.allMatches(valRaw)) {
      var part = token.group(1) ?? token.group(2) ?? '';
      part = part
          .replaceAll(r"\'", "'")
          .replaceAll(r'\"', '"')
          .replaceAll(r'\n', '\n');
      valParts.add(part);
    }
    final val = valParts.join();
    final hasTodo = commentInline.contains('TODO native speaker review') ||
        commentBefore.contains('TODO native speaker review');

    result[key] = _StringEntry(value: val, reviewed: !hasTodo);
  }

  return result;
}

String _escapeCsv(String field) {
  if (field.contains(',') ||
      field.contains('"') ||
      field.contains('\n') ||
      field.contains('\r')) {
    return '"${field.replaceAll('"', '""')}"';
  }
  return field;
}

