import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static ThemeData _buildTheme({
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
    final textTheme = GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.dmSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
        letterSpacing: -0.8,
      ),
      displayMedium: GoogleFonts.dmSans(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
        letterSpacing: -0.6,
      ),
      headlineMedium: GoogleFonts.dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
        letterSpacing: -0.4,
      ),
      headlineSmall: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
      ),
      titleLarge: GoogleFonts.dmSans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
        height: 1.45,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondaryColor,
        height: 1.45,
      ),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textPrimaryColor,
        letterSpacing: 0.1,
      ),
    );

    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius16),
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
          borderRadius: BorderRadius.circular(radius20),
          side: BorderSide(color: borderColor),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: chipBackgroundColor,
        selectedColor: chipSelectedColor,
        disabledColor: dividerColorValue,
        secondarySelectedColor: chipSecondarySelectedColor,
        padding: const EdgeInsets.symmetric(
          horizontal: space12,
          vertical: space8,
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
          borderRadius: BorderRadius.circular(radius16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: fabForegroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius16)),
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
          padding: const EdgeInsets.symmetric(
            horizontal: space20,
            vertical: space16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius16),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimaryColor,
          minimumSize: const Size.fromHeight(54),
          padding: const EdgeInsets.symmetric(
            horizontal: space20,
            vertical: space16,
          ),
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius16),
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius12),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space16,
          vertical: space16,
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
}
