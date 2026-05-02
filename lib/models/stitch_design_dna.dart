import 'package:flutter/material.dart';

class StitchDesignDna {
  const StitchDesignDna({
    required this.lightColors,
    required this.darkColors,
    required this.typography,
    required this.spacing,
    required this.radii,
    required this.raw,
  });

  final Map<String, Color> lightColors;
  final Map<String, Color> darkColors;
  final StitchTypography typography;
  final StitchSpacing spacing;
  final StitchRadii radii;
  final Map<String, dynamic> raw;

  factory StitchDesignDna.fromJson(Map<String, dynamic> json) {
    return StitchDesignDna(
      lightColors: _parseColorMap(_extractMap(json, const [
        'lightColors',
        'light_colors',
        'paletteLight',
      ])),
      darkColors: _parseColorMap(_extractMap(json, const [
        'darkColors',
        'dark_colors',
        'paletteDark',
      ])),
      typography: StitchTypography.fromJson(
        _extractMap(json, const ['typography', 'textStyles', 'fonts']),
      ),
      spacing: StitchSpacing.fromJson(
        _extractMap(json, const ['spacing', 'layoutSpacing']),
      ),
      radii: StitchRadii.fromJson(
        _extractMap(json, const ['radii', 'radius', 'corners']),
      ),
      raw: json,
    );
  }

  Color? lightColor(String key) => lightColors[key];
  Color? darkColor(String key) => darkColors[key];

  static Map<String, dynamic> _extractMap(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
    }
    return const {};
  }

  static Map<String, Color> _parseColorMap(Map<String, dynamic> source) {
    final colors = <String, Color>{};
    for (final entry in source.entries) {
      final color = _parseColor(entry.value);
      if (color != null) {
        colors[entry.key] = color;
      }
    }
    return colors;
  }

  static Color? _parseColor(dynamic value) {
    if (value is int) {
      return Color(value);
    }

    if (value is String) {
      final hex = value.replaceAll('#', '').trim();
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }

    if (value is Map<String, dynamic>) {
      final direct = value['value'] ?? value['hex'] ?? value['color'];
      if (direct != null) {
        return _parseColor(direct);
      }
      final r = (value['r'] as num?)?.toInt();
      final g = (value['g'] as num?)?.toInt();
      final b = (value['b'] as num?)?.toInt();
      final a = ((value['a'] as num?) ?? 1).toDouble();
      if (r != null && g != null && b != null) {
        return Color.fromRGBO(r, g, b, a);
      }
    }

    return null;
  }
}

class StitchTypography {
  const StitchTypography({
    required this.fontFamily,
    required this.displayLargeSize,
    required this.displayMediumSize,
    required this.headlineMediumSize,
    required this.headlineSmallSize,
    required this.titleLargeSize,
    required this.titleMediumSize,
    required this.bodyLargeSize,
    required this.bodyMediumSize,
    required this.labelLargeSize,
  });

  final String? fontFamily;
  final double? displayLargeSize;
  final double? displayMediumSize;
  final double? headlineMediumSize;
  final double? headlineSmallSize;
  final double? titleLargeSize;
  final double? titleMediumSize;
  final double? bodyLargeSize;
  final double? bodyMediumSize;
  final double? labelLargeSize;

  factory StitchTypography.fromJson(Map<String, dynamic> json) {
    return StitchTypography(
      fontFamily: _stringAt(json, const ['fontFamily', 'font_family', 'family']),
      displayLargeSize: _doubleAt(json, const ['displayLarge', 'display_large']),
      displayMediumSize: _doubleAt(json, const ['displayMedium', 'display_medium']),
      headlineMediumSize: _doubleAt(
        json,
        const ['headlineMedium', 'headline_medium'],
      ),
      headlineSmallSize: _doubleAt(
        json,
        const ['headlineSmall', 'headline_small'],
      ),
      titleLargeSize: _doubleAt(json, const ['titleLarge', 'title_large']),
      titleMediumSize: _doubleAt(json, const ['titleMedium', 'title_medium']),
      bodyLargeSize: _doubleAt(json, const ['bodyLarge', 'body_large']),
      bodyMediumSize: _doubleAt(json, const ['bodyMedium', 'body_medium']),
      labelLargeSize: _doubleAt(json, const ['labelLarge', 'label_large']),
    );
  }
}

class StitchSpacing {
  const StitchSpacing({
    required this.s4,
    required this.s8,
    required this.s12,
    required this.s16,
    required this.s20,
    required this.s24,
    required this.s28,
  });

  final double? s4;
  final double? s8;
  final double? s12;
  final double? s16;
  final double? s20;
  final double? s24;
  final double? s28;

  factory StitchSpacing.fromJson(Map<String, dynamic> json) {
    return StitchSpacing(
      s4: _doubleAt(json, const ['4', 'space4', 'xs']),
      s8: _doubleAt(json, const ['8', 'space8', 'sm']),
      s12: _doubleAt(json, const ['12', 'space12']),
      s16: _doubleAt(json, const ['16', 'space16', 'md']),
      s20: _doubleAt(json, const ['20', 'space20']),
      s24: _doubleAt(json, const ['24', 'space24', 'lg']),
      s28: _doubleAt(json, const ['28', 'space28', 'xl']),
    );
  }
}

class StitchRadii {
  const StitchRadii({
    required this.r12,
    required this.r16,
    required this.r20,
    required this.r24,
  });

  final double? r12;
  final double? r16;
  final double? r20;
  final double? r24;

  factory StitchRadii.fromJson(Map<String, dynamic> json) {
    return StitchRadii(
      r12: _doubleAt(json, const ['12', 'radius12', 'sm']),
      r16: _doubleAt(json, const ['16', 'radius16', 'md']),
      r20: _doubleAt(json, const ['20', 'radius20', 'lg']),
      r24: _doubleAt(json, const ['24', 'radius24', 'xl']),
    );
  }
}

double? _doubleAt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is Map<String, dynamic>) {
      final nested = value['value'] ?? value['size'];
      if (nested is num) {
        return nested.toDouble();
      }
    }
  }
  return null;
}

String? _stringAt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    if (value is Map<String, dynamic>) {
      final nested = value['value'] ?? value['name'];
      if (nested is String && nested.trim().isNotEmpty) {
        return nested.trim();
      }
    }
  }
  return null;
}
