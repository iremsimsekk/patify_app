import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/stitch_design_dna.dart';

class PatifyTheme {
  const PatifyTheme._();

  static const Color background = Color(0xFFF6F1EA);
  static const Color backgroundSoft = Color(0xFFFBF7F2);
  static const Color surface = Color(0xFFFFFCF8);
  static const Color surfaceRaised = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFFCA7B68);
  static const Color primarySoft = Color(0xFFF2DDD6);
  static const Color secondary = Color(0xFFA8B89C);
  static const Color secondarySoft = Color(0xFFE6EDE1);
  static const Color accent = Color(0xFFD9B56D);
  static const Color accentSoft = Color(0xFFF5E8C8);
  static const Color textPrimary = Color(0xFF2F2A28);
  static const Color textSecondary = Color(0xFF6B625D);
  static const Color border = Color(0xFFE7DED5);
  static const Color divider = Color(0xFFF0E7DE);
  static const Color success = Color(0xFF6E9A7A);
  static const Color danger = Color(0xFFC56D63);
  static const Color info = Color(0xFF7D98A6);

  static const Color darkBackground = Color(0xFF1F1A19);
  static const Color darkBackgroundSoft = Color(0xFF2A2422);
  static const Color darkSurface = Color(0xFF312A28);
  static const Color darkSurfaceRaised = Color(0xFF3A3230);
  static const Color darkPrimary = Color(0xFFD28B77);
  static const Color darkPrimarySoft = Color(0xFF5A413B);
  static const Color darkSecondary = Color(0xFF9FB096);
  static const Color darkSecondarySoft = Color(0xFF3B4740);
  static const Color darkAccent = Color(0xFFE2BF7E);
  static const Color darkTextPrimary = Color(0xFFF5ECE5);
  static const Color darkTextSecondary = Color(0xFFD0C0B6);
  static const Color darkBorder = Color(0xFF4A403D);
  static const Color darkDivider = Color(0xFF433935);

  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space28 = 28;
  static const double radius12 = 12;
  static const double radius16 = 16;
  static const double radius20 = 20;
  static const double radius24 = 24;

  static ThemeData get lightTheme => _buildTheme(
        dna: null,
        brightness: Brightness.light,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: primary,
          onPrimary: Colors.white,
          secondary: secondary,
          onSecondary: textPrimary,
          error: danger,
          onError: Colors.white,
          surface: surface,
          onSurface: textPrimary,
        ),
        scaffoldColor: background,
        canvasColor: background,
        appBarColor: backgroundSoft,
        cardColor: surfaceRaised,
        dividerColorValue: divider,
        iconColor: textPrimary,
        textPrimaryColor: textPrimary,
        textSecondaryColor: textSecondary,
        borderColor: border,
        chipBackgroundColor: surfaceRaised,
        chipSelectedColor: primarySoft,
        chipSecondarySelectedColor: secondarySoft,
        snackBarBackgroundColor: textPrimary,
        fabForegroundColor: Colors.white,
        navigationIndicatorColor: primarySoft,
      );

  static ThemeData get darkTheme => _buildTheme(
        dna: null,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: darkPrimary,
          onPrimary: Colors.white,
          secondary: darkSecondary,
          onSecondary: darkTextPrimary,
          error: danger,
          onError: Colors.white,
          surface: darkSurface,
          onSurface: darkTextPrimary,
        ),
        scaffoldColor: darkBackground,
        canvasColor: darkBackground,
        appBarColor: darkBackgroundSoft,
        cardColor: darkSurfaceRaised,
        dividerColorValue: darkDivider,
        iconColor: darkTextPrimary,
        textPrimaryColor: darkTextPrimary,
        textSecondaryColor: darkTextSecondary,
        borderColor: darkBorder,
        chipBackgroundColor: darkSurfaceRaised,
        chipSelectedColor: darkPrimarySoft,
        chipSecondarySelectedColor: darkSecondarySoft,
        snackBarBackgroundColor: darkSurfaceRaised,
        fabForegroundColor: Colors.white,
        navigationIndicatorColor: darkPrimarySoft,
      );

  static ThemeData lightThemeFromDna(StitchDesignDna? dna) {
    final colors = _ThemeColors.light(dna);
    return _buildTheme(
      dna: dna,
      brightness: Brightness.light,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: colors.primary,
        onPrimary: Colors.white,
        secondary: colors.secondary,
        onSecondary: colors.textPrimary,
        error: colors.danger,
        onError: Colors.white,
        surface: colors.surface,
        onSurface: colors.textPrimary,
      ),
      scaffoldColor: colors.background,
      canvasColor: colors.background,
      appBarColor: colors.backgroundSoft,
      cardColor: colors.surfaceRaised,
      dividerColorValue: colors.divider,
      iconColor: colors.textPrimary,
      textPrimaryColor: colors.textPrimary,
      textSecondaryColor: colors.textSecondary,
      borderColor: colors.border,
      chipBackgroundColor: colors.surfaceRaised,
      chipSelectedColor: colors.primarySoft,
      chipSecondarySelectedColor: colors.secondarySoft,
      snackBarBackgroundColor: colors.textPrimary,
      fabForegroundColor: Colors.white,
      navigationIndicatorColor: colors.primarySoft,
    );
  }

  static ThemeData darkThemeFromDna(StitchDesignDna? dna) {
    final colors = _ThemeColors.dark(dna);
    return _buildTheme(
      dna: dna,
      brightness: Brightness.dark,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: colors.primary,
        onPrimary: Colors.white,
        secondary: colors.secondary,
        onSecondary: colors.textPrimary,
        error: colors.danger,
        onError: Colors.white,
        surface: colors.surface,
        onSurface: colors.textPrimary,
      ),
      scaffoldColor: colors.background,
      canvasColor: colors.background,
      appBarColor: colors.backgroundSoft,
      cardColor: colors.surfaceRaised,
      dividerColorValue: colors.divider,
      iconColor: colors.textPrimary,
      textPrimaryColor: colors.textPrimary,
      textSecondaryColor: colors.textSecondary,
      borderColor: colors.border,
      chipBackgroundColor: colors.surfaceRaised,
      chipSelectedColor: colors.primarySoft,
      chipSecondarySelectedColor: colors.secondarySoft,
      snackBarBackgroundColor: colors.surfaceRaised,
      fabForegroundColor: Colors.white,
      navigationIndicatorColor: colors.primarySoft,
    );
  }

  static ThemeData _buildTheme({
    required StitchDesignDna? dna,
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldColor,
    required Color canvasColor,
    required Color appBarColor,
    required Color cardColor,
    required Color dividerColorValue,
    required Color iconColor,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
    required Color borderColor,
    required Color chipBackgroundColor,
    required Color chipSelectedColor,
    required Color chipSecondarySelectedColor,
    required Color snackBarBackgroundColor,
    required Color fabForegroundColor,
    required Color navigationIndicatorColor,
  }) {
    final base = ThemeData(useMaterial3: true, colorScheme: colorScheme);
    final typography = dna?.typography;
    final textTheme = _baseTextTheme(
      base.textTheme,
      typography?.fontFamily,
    ).copyWith(
      displayLarge: _font(
        typography?.fontFamily,
        fontSize: typography?.displayLargeSize ?? 32,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
        letterSpacing: -0.8,
      ),
      displayMedium: _font(
        typography?.fontFamily,
        fontSize: typography?.displayMediumSize ?? 26,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
        letterSpacing: -0.6,
      ),
      headlineMedium: _font(
        typography?.fontFamily,
        fontSize: typography?.headlineMediumSize ?? 22,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
        letterSpacing: -0.4,
      ),
      headlineSmall: _font(
        typography?.fontFamily,
        fontSize: typography?.headlineSmallSize ?? 18,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
      ),
      titleLarge: _font(
        typography?.fontFamily,
        fontSize: typography?.titleLargeSize ?? 17,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
      ),
      titleMedium: _font(
        typography?.fontFamily,
        fontSize: typography?.titleMediumSize ?? 16,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      bodyLarge: _font(
        typography?.fontFamily,
        fontSize: typography?.bodyLargeSize ?? 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
        height: 1.45,
      ),
      bodyMedium: _font(
        typography?.fontFamily,
        fontSize: typography?.bodyMediumSize ?? 14,
        fontWeight: FontWeight.w500,
        color: textSecondaryColor,
        height: 1.45,
      ),
      labelLarge: _font(
        typography?.fontFamily,
        fontSize: typography?.labelLargeSize ?? 14,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
        letterSpacing: 0.1,
      ),
    );

    final radii = _ThemeRadii.fromDna(dna);
    final spacing = _ThemeSpacing.fromDna(dna);

    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radii.r16),
      borderSide: BorderSide(color: borderColor),
    );

    return base.copyWith(
      scaffoldBackgroundColor: scaffoldColor,
      canvasColor: canvasColor,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: iconColor, size: 22),
      dividerColor: dividerColorValue,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        toolbarHeight: 64,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: iconColor, size: 22),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 1.5,
        shadowColor: textPrimaryColor.withValues(alpha: 0.06),
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.only(bottom: space12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.r20),
          side: BorderSide(color: borderColor),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: chipBackgroundColor,
        selectedColor: chipSelectedColor,
        disabledColor: dividerColorValue,
        secondarySelectedColor: chipSecondarySelectedColor,
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s12,
          vertical: spacing.s8,
        ),
        labelStyle: textTheme.labelLarge!,
        secondaryLabelStyle: textTheme.labelLarge!,
        brightness: colorScheme.brightness,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: borderColor),
        ),
        side: BorderSide(color: borderColor),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColorValue,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: snackBarBackgroundColor,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onPrimary,
        ),
        actionTextColor: colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.r16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: fabForegroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radii.r16)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: navigationIndicatorColor,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colorScheme.primary : textSecondaryColor,
            size: selected ? 24 : 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium!.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? colorScheme.primary : textSecondaryColor,
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.45),
          disabledForegroundColor: colorScheme.onPrimary.withValues(alpha: 0.8),
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(54),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s20,
            vertical: spacing.s16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radii.r16),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimaryColor,
          minimumSize: const Size.fromHeight(54),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.s20,
            vertical: spacing.s16,
          ),
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radii.r16),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radii.r12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: textSecondaryColor.withValues(alpha: 0.85),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondaryColor),
        prefixIconColor: textSecondaryColor,
        suffixIconColor: textSecondaryColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing.s16,
          vertical: spacing.s16,
        ),
        border: outlineBorder,
        enabledBorder: outlineBorder,
        focusedBorder: outlineBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
        ),
        errorBorder: outlineBorder.copyWith(
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: outlineBorder.copyWith(
          borderSide: const BorderSide(color: danger, width: 1.2),
        ),
      ),
    );
  }

  static TextTheme _baseTextTheme(TextTheme base, String? fontFamily) {
    if (fontFamily != null && fontFamily.isNotEmpty) {
      try {
        return GoogleFonts.getTextTheme(fontFamily, base);
      } catch (_) {
        return GoogleFonts.dmSansTextTheme(base);
      }
    }
    return GoogleFonts.dmSansTextTheme(base);
  }

  static TextStyle _font(
    String? fontFamily, {
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? letterSpacing,
    double? height,
  }) {
    if (fontFamily != null && fontFamily.isNotEmpty) {
      try {
        return GoogleFonts.getFont(
          fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
        );
      } catch (_) {}
    }

    return GoogleFonts.dmSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}

class _ThemeSpacing {
  const _ThemeSpacing({
    required this.s8,
    required this.s12,
    required this.s16,
    required this.s20,
  });

  final double s8;
  final double s12;
  final double s16;
  final double s20;

  factory _ThemeSpacing.fromDna(StitchDesignDna? dna) {
    return _ThemeSpacing(
      s8: dna?.spacing.s8 ?? PatifyTheme.space8,
      s12: dna?.spacing.s12 ?? PatifyTheme.space12,
      s16: dna?.spacing.s16 ?? PatifyTheme.space16,
      s20: dna?.spacing.s20 ?? PatifyTheme.space20,
    );
  }
}

class _ThemeRadii {
  const _ThemeRadii({
    required this.r12,
    required this.r16,
    required this.r20,
  });

  final double r12;
  final double r16;
  final double r20;

  factory _ThemeRadii.fromDna(StitchDesignDna? dna) {
    return _ThemeRadii(
      r12: dna?.radii.r12 ?? PatifyTheme.radius12,
      r16: dna?.radii.r16 ?? PatifyTheme.radius16,
      r20: dna?.radii.r20 ?? PatifyTheme.radius20,
    );
  }
}

class _ThemeColors {
  const _ThemeColors({
    required this.background,
    required this.backgroundSoft,
    required this.surface,
    required this.surfaceRaised,
    required this.primary,
    required this.primarySoft,
    required this.secondary,
    required this.secondarySoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.divider,
    required this.danger,
  });

  final Color background;
  final Color backgroundSoft;
  final Color surface;
  final Color surfaceRaised;
  final Color primary;
  final Color primarySoft;
  final Color secondary;
  final Color secondarySoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color divider;
  final Color danger;

  factory _ThemeColors.light(StitchDesignDna? dna) {
    return _ThemeColors(
      background: dna?.lightColor('background') ?? PatifyTheme.background,
      backgroundSoft:
          dna?.lightColor('backgroundSoft') ?? PatifyTheme.backgroundSoft,
      surface: dna?.lightColor('surface') ?? PatifyTheme.surface,
      surfaceRaised:
          dna?.lightColor('surfaceRaised') ?? PatifyTheme.surfaceRaised,
      primary: dna?.lightColor('primary') ?? PatifyTheme.primary,
      primarySoft: dna?.lightColor('primarySoft') ?? PatifyTheme.primarySoft,
      secondary: dna?.lightColor('secondary') ?? PatifyTheme.secondary,
      secondarySoft:
          dna?.lightColor('secondarySoft') ?? PatifyTheme.secondarySoft,
      textPrimary:
          dna?.lightColor('textPrimary') ?? PatifyTheme.textPrimary,
      textSecondary:
          dna?.lightColor('textSecondary') ?? PatifyTheme.textSecondary,
      border: dna?.lightColor('border') ?? PatifyTheme.border,
      divider: dna?.lightColor('divider') ?? PatifyTheme.divider,
      danger: dna?.lightColor('danger') ?? PatifyTheme.danger,
    );
  }

  factory _ThemeColors.dark(StitchDesignDna? dna) {
    return _ThemeColors(
      background: dna?.darkColor('background') ?? PatifyTheme.darkBackground,
      backgroundSoft:
          dna?.darkColor('backgroundSoft') ?? PatifyTheme.darkBackgroundSoft,
      surface: dna?.darkColor('surface') ?? PatifyTheme.darkSurface,
      surfaceRaised:
          dna?.darkColor('surfaceRaised') ?? PatifyTheme.darkSurfaceRaised,
      primary: dna?.darkColor('primary') ?? PatifyTheme.darkPrimary,
      primarySoft:
          dna?.darkColor('primarySoft') ?? PatifyTheme.darkPrimarySoft,
      secondary: dna?.darkColor('secondary') ?? PatifyTheme.darkSecondary,
      secondarySoft:
          dna?.darkColor('secondarySoft') ?? PatifyTheme.darkSecondarySoft,
      textPrimary:
          dna?.darkColor('textPrimary') ?? PatifyTheme.darkTextPrimary,
      textSecondary:
          dna?.darkColor('textSecondary') ?? PatifyTheme.darkTextSecondary,
      border: dna?.darkColor('border') ?? PatifyTheme.darkBorder,
      divider: dna?.darkColor('divider') ?? PatifyTheme.darkDivider,
      danger: dna?.darkColor('danger') ?? PatifyTheme.danger,
    );
  }
}
