// ignore_for_file: avoid_print
/// Codegen: reads tokens.json + themes/{dark,light}.json → lib/core/theme/generated/
/// Usage: dart tool/gen_theme.dart
/// Idempotent: re-running produces no diff.
library;

import 'dart:convert';
import 'dart:io';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

void main() {
  final root = _findProjectRoot();
  final tokens = _loadJson('$root/docs/design-system/tokens.json');
  final dark = _loadJson('$root/docs/design-system/themes/dark.json');
  final light = _loadJson('$root/docs/design-system/themes/light.json');

  final outDir = '$root/lib/core/theme/generated';
  Directory(outDir).createSync(recursive: true);

  _writeIfChanged('$outDir/color_tokens.dart', _emitColors(dark, light));
  _writeIfChanged('$outDir/spacing_tokens.dart', _emitSpacing(tokens));
  _writeIfChanged('$outDir/typography_tokens.dart', _emitTypography(tokens));
  _writeIfChanged('$outDir/radius_tokens.dart', _emitRadius(tokens));
  _writeIfChanged('$outDir/motion_tokens.dart', _emitMotion(tokens));

  print('gen_theme: done — 5 files written to lib/core/theme/generated/');
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _findProjectRoot() {
  var dir = Directory.current;
  while (!File('${dir.path}/pubspec.yaml').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) throw StateError('pubspec.yaml not found');
    dir = parent;
  }
  return dir.path;
}

Map<String, dynamic> _loadJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

/// Write file only if content changed (idempotency).
void _writeIfChanged(String path, String content) {
  final file = File(path);
  if (file.existsSync() && file.readAsStringSync() == content) return;
  file.writeAsStringSync(content);
}

// ---------------------------------------------------------------------------
// Hex → Flutter Color literal  (handles 6-digit and 8-digit hex)
// ---------------------------------------------------------------------------

String _hexToColor(String hex) {
  final h = hex.replaceFirst('#', '');
  if (h.length == 6) return 'Color(0xFF${h.toUpperCase()})';
  if (h.length == 8) {
    // DTCG: #RRGGBBAA → Flutter needs 0xAARRGGBB
    final rr = h.substring(0, 2);
    final gg = h.substring(2, 4);
    final bb = h.substring(4, 6);
    final aa = h.substring(6, 8);
    return 'Color(0x${aa.toUpperCase()}${rr.toUpperCase()}${gg.toUpperCase()}${bb.toUpperCase()})';
  }
  throw FormatException('Bad hex: $hex');
}

/// Flatten a nested DTCG color group into (identifier → hex) pairs.
/// Only leaf nodes with `$value` + `$type == color` are emitted.
void _flattenColors(
  Map<String, dynamic> node,
  List<String> path,
  Map<String, String> out,
) {
  if (node.containsKey(r'$value') && node[r'$type'] == 'color') {
    final name = path
        .join('_')
        .replaceAll('-', '_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    out[name] = node[r'$value'] as String;
    return;
  }
  for (final entry in node.entries) {
    if (entry.key.startsWith(r'$')) continue;
    final v = entry.value;
    if (v is Map<String, dynamic>) {
      _flattenColors(v, [...path, entry.key], out);
    }
  }
}

// ---------------------------------------------------------------------------
// Emitters
// ---------------------------------------------------------------------------

String _emitColors(
  Map<String, dynamic> dark,
  Map<String, dynamic> light,
) {
  final darkColors = <String, String>{};
  final lightColors = <String, String>{};

  final darkColor = dark['color'] as Map<String, dynamic>;
  final lightColor = light['color'] as Map<String, dynamic>;
  _flattenColors(darkColor, [], darkColors);
  _flattenColors(lightColor, [], lightColors);

  final buf = StringBuffer();
  buf.writeln(_header('Color tokens — generated from themes/dark.json and themes/light.json'));
  buf.writeln("import 'package:flutter/painting.dart';");
  buf.writeln();
  buf.writeln('// ignore_for_file: constant_identifier_names');
  buf.writeln();

  buf.writeln('/// Dark theme color constants.');
  buf.writeln('abstract final class DarkColorTokens {');
  for (final e in darkColors.entries) {
    buf.writeln('  static const ${e.key} = ${_hexToColor(e.value)};');
  }
  buf.writeln('}');
  buf.writeln();

  buf.writeln('/// Light theme color constants.');
  buf.writeln('abstract final class LightColorTokens {');
  for (final e in lightColors.entries) {
    buf.writeln('  static const ${e.key} = ${_hexToColor(e.value)};');
  }
  buf.writeln('}');

  return buf.toString();
}

String _emitSpacing(Map<String, dynamic> tokens) {
  final spacing =
      (tokens['dimension'] as Map<String, dynamic>)['spacing'] as Map<String, dynamic>;
  final buf = StringBuffer();
  buf.writeln(_header('Spacing tokens — generated from tokens.json dimension.spacing'));
  buf.writeln('// ignore_for_file: constant_identifier_names');
  buf.writeln();
  buf.writeln('/// M3 8dp grid spacing constants.');
  buf.writeln('abstract final class SpacingTokens {');
  for (final e in spacing.entries) {
    if (e.key.startsWith(r'$')) continue;
    final px = (e.value as Map<String, dynamic>)[r'$value'] as String;
    final dp = double.parse(px.replaceAll('px', ''));
    buf.writeln('  /// $px');
    buf.writeln('  static const double s${e.key} = $dp;');
  }
  buf.writeln('}');
  return buf.toString();
}

String _emitTypography(Map<String, dynamic> tokens) {
  final sizes = tokens['fontSize'] as Map<String, dynamic>;
  final weights = tokens['fontWeight'] as Map<String, dynamic>;
  final lineHeights = tokens['lineHeight'] as Map<String, dynamic>;
  final families = tokens['fontFamily'] as Map<String, dynamic>;

  final buf = StringBuffer();
  buf.writeln(_header('Typography tokens — generated from tokens.json'));
  buf.writeln('// ignore_for_file: constant_identifier_names');
  buf.writeln();

  buf.writeln('/// Font size constants (sp / logical pixels).');
  buf.writeln('abstract final class FontSizeTokens {');
  for (final e in sizes.entries) {
    if (e.key.startsWith(r'$')) continue;
    final px = (e.value as Map<String, dynamic>)[r'$value'] as String;
    final dp = double.parse(px.replaceAll('px', ''));
    final id = e.key.replaceAll('-', '_');
    buf.writeln('  static const double $id = $dp;');
  }
  buf.writeln('}');
  buf.writeln();

  buf.writeln('/// Font weight constants.');
  buf.writeln('abstract final class FontWeightTokens {');
  for (final e in weights.entries) {
    final w = (e.value as Map<String, dynamic>)[r'$value'];
    buf.writeln('  static const int ${e.key} = $w;');
  }
  buf.writeln('}');
  buf.writeln();

  buf.writeln('/// Line height ratios.');
  buf.writeln('abstract final class LineHeightTokens {');
  for (final e in lineHeights.entries) {
    if (e.key.startsWith(r'$')) continue;
    final v = (e.value as Map<String, dynamic>)[r'$value'];
    final id = e.key.replaceAll('-', '_');
    buf.writeln('  static const double $id = $v;');
  }
  buf.writeln('}');
  buf.writeln();

  buf.writeln('/// Font family names.');
  buf.writeln('abstract final class FontFamilyTokens {');
  for (final e in families.entries) {
    if (e.key.startsWith(r'$')) continue;
    final vals = (e.value as Map<String, dynamic>)[r'$value'] as List<dynamic>;
    final primary = vals.first as String;
    buf.writeln("  static const String ${e.key} = '$primary';");
  }
  buf.writeln('}');

  return buf.toString();
}

String _emitRadius(Map<String, dynamic> tokens) {
  final shape =
      (tokens['dimension'] as Map<String, dynamic>)['shape'] as Map<String, dynamic>;
  final buf = StringBuffer();
  buf.writeln(_header('Radius tokens — generated from tokens.json dimension.shape'));
  buf.writeln('// ignore_for_file: constant_identifier_names');
  buf.writeln();
  buf.writeln('/// M3 shape-scale radius constants.');
  buf.writeln('abstract final class RadiusTokens {');
  for (final e in shape.entries) {
    if (e.key.startsWith(r'$')) continue;
    final px = (e.value as Map<String, dynamic>)[r'$value'] as String;
    final dp = double.parse(px.replaceAll('px', ''));
    final id = e.key.replaceAll('-', '_');
    buf.writeln('  static const double $id = $dp;');
  }
  buf.writeln('}');
  return buf.toString();
}

String _emitMotion(Map<String, dynamic> tokens) {
  final durations = tokens['duration'] as Map<String, dynamic>;
  final buf = StringBuffer();
  buf.writeln(_header('Motion tokens — generated from tokens.json duration'));
  buf.writeln("import 'package:flutter/animation.dart';");
  buf.writeln();
  buf.writeln('// ignore_for_file: constant_identifier_names');
  buf.writeln();
  buf.writeln('/// M3 motion duration constants.');
  buf.writeln('abstract final class DurationTokens {');
  for (final e in durations.entries) {
    if (e.key.startsWith(r'$')) continue;
    final ms = (e.value as Map<String, dynamic>)[r'$value'] as String;
    final millis = int.parse(ms.replaceAll('ms', ''));
    final id = e.key.replaceAll('-', '_');
    buf.writeln('  static const Duration $id = Duration(milliseconds: $millis);');
  }
  buf.writeln('}');
  buf.writeln();
  buf.writeln('/// M3 standard easing curves.');
  buf.writeln('abstract final class EasingTokens {');
  buf.writeln('  static const Curve standard = Curves.easeInOut;');
  buf.writeln('  static const Curve emphasized = Curves.easeInOutCubicEmphasized;');
  buf.writeln('  static const Curve decelerate = Curves.decelerate;');
  buf.writeln('  static const Curve linear = Curves.linear;');
  buf.writeln('}');
  return buf.toString();
}

String _header(String description) =>
    '// GENERATED FILE — do not edit by hand.\n'
    '// Re-generate: dart tool/gen_theme.dart\n'
    '// $description\n'
    '// ignore_for_file: lines_longer_than_80_chars\n';
