import 'dart:io';

/// Reads `tools/strings.csv` and regenerates the Sinhala map `_si` in `lib/app/strings.dart`.
///
/// Keeps the English fallback when a Sinhala cell is empty.
/// Keeps `// TODO native speaker review` marker on entries not yet marked reviewed.
void main() {
  final root = Directory.current;
  final csvFile = File('${root.path}/tools/strings.csv');
  final stringsFile = File('${root.path}/lib/app/strings.dart');

  if (!csvFile.existsSync()) {
    stderr.writeln('Cannot find ${csvFile.path}');
    exit(1);
  }
  if (!stringsFile.existsSync()) {
    stderr.writeln('Cannot find ${stringsFile.path}');
    exit(1);
  }

  final csvContent = csvFile.readAsStringSync();
  final records = _parseCsv(csvContent);
  if (records.isEmpty) {
    stderr.writeln('CSV is empty');
    exit(1);
  }

  final header = records.first.map((c) => c.trim().toLowerCase()).toList();
  final keyIdx = header.indexOf('key');
  final siIdx = header.indexOf('sinhala');
  final revIdx = header.indexOf('reviewed');

  if (keyIdx == -1 || siIdx == -1) {
    stderr.writeln('CSV must contain "key" and "sinhala" columns');
    exit(1);
  }

  final hasReviewedCol = revIdx != -1;
  final siLines = <String>['const _si = <String, String>{'];

  for (var i = 1; i < records.length; i++) {
    final row = records[i];
    if (row.length <= keyIdx || row.length <= siIdx) continue;
    final key = row[keyIdx].trim();
    final sinhala = row[siIdx].trim();
    if (key.isEmpty || sinhala.isEmpty) {
      // Empty Sinhala cell: falls back to English, so omit from _si
      continue;
    }

    final reviewedVal = hasReviewedCol && row.length > revIdx
        ? row[revIdx].trim().toLowerCase()
        : '';
    final isReviewed = hasReviewedCol &&
        (reviewedVal == 'yes' || reviewedVal == 'true' || reviewedVal == '1');

    final dartVal = _formatDartString(sinhala);
    final comment = isReviewed ? '' : ' // TODO native speaker review';
    siLines.add("  '$key': $dartVal,$comment");
  }

  siLines.add('};');
  final newSiBlock = siLines.join('\n');

  final currentContent = stringsFile.readAsStringSync();
  final siPattern = RegExp(
    r'const\s+_si\s*=\s*<String,\s*String>\s*\{.*?\};',
    dotAll: true,
  );

  if (!siPattern.hasMatch(currentContent)) {
    stderr.writeln('Could not locate const _si map in ${stringsFile.path}');
    exit(1);
  }

  final updated = currentContent.replaceFirst(siPattern, newSiBlock);
  stringsFile.writeAsStringSync(updated);

  stdout.writeln('Successfully regenerated _si map in ${stringsFile.path}');
}

String _formatDartString(String val) {
  final clean = val.replaceAll('\n', r'\n');
  if (!clean.contains("'")) {
    return "'$clean'";
  } else if (!clean.contains('"')) {
    return '"$clean"';
  } else {
    final escaped = clean.replaceAll("'", r"\'");
    return "'$escaped'";
  }
}

List<List<String>> _parseCsv(String input) {
  final rows = <List<String>>[];
  final currentRow = <String>[];
  final currentField = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < input.length; i++) {
    final char = input[i];

    if (inQuotes) {
      if (char == '"') {
        if (i + 1 < input.length && input[i + 1] == '"') {
          currentField.write('"');
          i++; // skip escaped quote
        } else {
          inQuotes = false;
        }
      } else {
        currentField.write(char);
      }
    } else {
      if (char == '"') {
        inQuotes = true;
      } else if (char == ',') {
        currentRow.add(currentField.toString());
        currentField.clear();
      } else if (char == '\r') {
        if (i + 1 < input.length && input[i + 1] == '\n') {
          i++;
        }
        currentRow.add(currentField.toString());
        currentField.clear();
        rows.add(List.from(currentRow));
        currentRow.clear();
      } else if (char == '\n') {
        currentRow.add(currentField.toString());
        currentField.clear();
        rows.add(List.from(currentRow));
        currentRow.clear();
      } else {
        currentField.write(char);
      }
    }
  }

  if (currentField.isNotEmpty || currentRow.isNotEmpty) {
    currentRow.add(currentField.toString());
    rows.add(currentRow);
  }

  return rows;
}

