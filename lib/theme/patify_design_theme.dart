import 'package:flutter/material.dart';

import '../models/stitch_design_dna.dart';
import 'patify_theme.dart';

class PatifyDesignTheme {
  const PatifyDesignTheme._();

  static ThemeData light(StitchDesignDna? dna) {
    return PatifyTheme.lightThemeFromDna(dna);
  }

  static ThemeData dark(StitchDesignDna? dna) {
    return PatifyTheme.darkThemeFromDna(dna);
  }
}
