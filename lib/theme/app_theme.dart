import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors
  static const babyPink = Color(0xFFFFC0CB);
  static const softLavender = Color(0xFFE6CCFF);
  static const cream = Color(0xFFFFF5E1);
  static const newPinkLight = Color(
      0xFFFFEBF0); // Soft visible pink, lighter than original but still noticeable
  static const chipUnselected =
      Color(0xFFFFDDE5); // Unselected chip - soft pink
  static const chipSelected = Color(0xFFE8547A); // Selected chip - dark pink
  static const mint = Color(0xFFDFF5E1);
  static const peach = Color(0xFFFFD9C0);
  static const lilac = Color(0xFFD4B8E0);
  static const roseGold = Color(0xFFE8A0A0);
  static const softWhite = Color(0xFFFFFAFD);
  static const cardWhite = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF4A3F5C);
  static const textMedium = Color(0xFF7B6B8D);
  static const textLight = Color(0xFFB0A0C0);
  static const shadowColor = Color(0x1A9B8BB0);
  static const streakOrange = Color(0xFFFF8C42);
  static const streakGold = Color(0xFFFFD700);
  static const successGreen = Color(0xFF7BC67E);
  static const errorRed = Color(0xFFFF8A8A);

  // Dark Mode Colors
  static const darkBackground = Color(0xFF1A1625);
  static const darkSurface = Color(0xFF251E35);
  static const darkCard = Color(0xFF2D2540);
  static const darkCardElevated = Color(0xFF362D4A);
  static const darkTextPrimary = Color(0xFFE8D5FF);
  static const darkTextSecondary = Color(0xFFB8A0D0);
  static const darkTextTertiary = Color(0xFF8B7BA0);
  static const darkAccentPink = Color(0xFFFF9EC7);
  static const darkAccentLavender = Color(0xFFC4A0E8);
  static const darkAccentMint = Color(0xFF7FD8A0);
  static const darkAccentPeach = Color(0xFFFFB88C);
  static const darkShadow = Color(0x40000000);

  // Light Mode Gradients
  static const gradientPink = LinearGradient(
    colors: [Color(0xFFFFAABF), Color(0xFFFD4C79)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientNewPink = LinearGradient(
    colors: [
      Color(0xFFFFD9E3), // Color.fromARGB(255, 255, 217, 227) converted to hex
      Color(0xFFFFB1C4) // Color.fromARGB(255, 255, 177, 196) converted to hex
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientLavender = LinearGradient(
    colors: [Color(0xFFEDD9FF), Color(0xFFD4B8E0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientMint = LinearGradient(
    colors: [Color(0xFFE8F8EC), Color(0xFFBFEDCA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientPeach = LinearGradient(
    colors: [Color(0xFFFFEDD5), Color(0xFFFFCBA4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientBackground = LinearGradient(
    colors: [Color(0xFFFFF0F5), Color(0xFFF5EEFF), Color(0xFFFFF5E1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Dark Mode Gradients
  static const gradientPinkDark = LinearGradient(
    colors: [Color(0xFF4A2D47), Color(0xFF5C3555)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientLavenderDark = LinearGradient(
    colors: [Color(0xFF3D2F5C), Color(0xFF4A3768)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientMintDark = LinearGradient(
    colors: [Color(0xFF2D4A3D), Color(0xFF3A5C4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientPeachDark = LinearGradient(
    colors: [Color(0xFF4A3D2D), Color(0xFF5C4A37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientBackgroundDark = LinearGradient(
    colors: [Color(0xFF1A1625), Color(0xFF221A30), Color(0xFF1E1A28)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Extra unique gradients - Light
  static const gradientSky = LinearGradient(
    colors: [Color(0xFFD6EEFF), Color(0xFFADD8F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientRose = LinearGradient(
    colors: [Color(0xFFFFD6E0), Color(0xFFFFAEC0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientLemon = LinearGradient(
    colors: [Color(0xFFFFF9C4), Color(0xFFFFEE82)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientLilacMist = LinearGradient(
    colors: [Color(0xFFEDE0FF), Color(0xFFCFB3F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientCoral = LinearGradient(
    colors: [Color(0xFFFFE0D6), Color(0xFFFFB8A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientAqua = LinearGradient(
    colors: [Color(0xFFD6FFF6), Color(0xFF9FEDD7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Extra unique gradients - Dark
  static const gradientSkyDark = LinearGradient(
    colors: [Color(0xFF1A3A4A), Color(0xFF1E4D63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientRoseDark = LinearGradient(
    colors: [Color(0xFF4A1A2D), Color(0xFF5C2038)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientLemonDark = LinearGradient(
    colors: [Color(0xFF3A3A1A), Color(0xFF4A4A20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientLilacMistDark = LinearGradient(
    colors: [Color(0xFF2D1A4A), Color(0xFF3A2060)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientCoralDark = LinearGradient(
    colors: [Color(0xFF4A2A1A), Color(0xFF5C3020)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const gradientAquaDark = LinearGradient(
    colors: [Color(0xFF1A3A35), Color(0xFF1E4A42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppFonts {
  static const mySunshine = 'MySunshine';
  static const nclGasdrifo = 'NCLGasdrifo';
  static const crustaceansSignature = 'CrustaceansSignature';
}

class AppTextStyles {
  // NCLGasdrifo — display titles
  static TextStyle display({
    double fontSize = 36,
    required Color color,
    FontWeight weight = FontWeight.w400,
  }) =>
      TextStyle(
        fontFamily: AppFonts.nclGasdrifo,
        fontSize: fontSize,
        color: color,
        fontWeight: weight,
        letterSpacing: 2,
        height: 2,
      );

  // NCLGasdrifo — section headings
  static TextStyle heading({
    double fontSize = 22,
    required Color color,
    FontWeight weight = FontWeight.w400,
  }) =>
      TextStyle(
        fontFamily: AppFonts.nclGasdrifo,
        fontSize: fontSize,
        color: color,
        fontWeight: weight,
        letterSpacing: 1.1,
        height: 1.3,
      );

  // NCLGasdrifo — quotes, onboarding, signature moments
  static TextStyle signature({
    double fontSize = 24,
    required Color color,
    FontWeight weight = FontWeight.w400,
  }) =>
      TextStyle(
        fontFamily: AppFonts.nclGasdrifo,
        fontSize: fontSize,
        color: color,
        fontWeight: weight,
        height: 1.4,
      );

  // NCLGasdrifo — body, labels, UI text everywhere
  static TextStyle body({
    double fontSize = 14,
    required Color color,
    FontWeight weight = FontWeight.w400,
  }) =>
      TextStyle(
        fontFamily: AppFonts.nclGasdrifo,
        fontSize: fontSize,
        color: color,
        fontWeight: weight,
        height: 1.5,
      );

  static TextStyle label({
    double fontSize = 12,
    required Color color,
    FontWeight weight = FontWeight.w600,
  }) =>
      TextStyle(
        fontFamily: AppFonts.nclGasdrifo,
        fontSize: fontSize,
        color: color,
        fontWeight: weight,
        letterSpacing: 1,
      );

  static TextStyle button({
    double fontSize = 15,
    Color color = Colors.white,
  }) =>
      TextStyle(
        fontFamily: AppFonts.nclGasdrifo,
        fontSize: fontSize,
        color: color,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      );
}

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    final tt = TextTheme(
      displayLarge:
          AppTextStyles.display(fontSize: 32, color: AppColors.textDark),
      displayMedium:
          AppTextStyles.display(fontSize: 26, color: AppColors.textDark),
      displaySmall:
          AppTextStyles.display(fontSize: 22, color: AppColors.textDark),
      headlineLarge:
          AppTextStyles.heading(fontSize: 22, color: AppColors.textDark),
      headlineMedium:
          AppTextStyles.heading(fontSize: 18, color: AppColors.textDark),
      headlineSmall:
          AppTextStyles.heading(fontSize: 16, color: AppColors.textDark),
      titleLarge: AppTextStyles.body(
        fontSize: 16,
        color: AppColors.textDark,
        weight: FontWeight.w700,
      ),
      titleMedium: AppTextStyles.body(
        fontSize: 14,
        color: AppColors.textDark,
        weight: FontWeight.w600,
      ),
      titleSmall: AppTextStyles.body(
        fontSize: 13,
        color: AppColors.textDark,
        weight: FontWeight.w600,
      ),
      bodyLarge: AppTextStyles.body(fontSize: 15, color: AppColors.textMedium),
      bodyMedium: AppTextStyles.body(fontSize: 13, color: AppColors.textMedium),
      bodySmall: AppTextStyles.body(fontSize: 11, color: AppColors.textLight),
      labelLarge: AppTextStyles.label(fontSize: 14, color: AppColors.textDark),
      labelMedium:
          AppTextStyles.label(fontSize: 12, color: AppColors.textMedium),
      labelSmall: AppTextStyles.label(fontSize: 10, color: AppColors.textLight),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.nclGasdrifo,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.babyPink,
        brightness: Brightness.light,
        surface: AppColors.softWhite,
      ),
      scaffoldBackgroundColor: AppColors.softWhite,
      textTheme: tt,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: AppColors.cardWhite,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.babyPink,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTextStyles.button(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.newPinkLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.babyPink, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: AppTextStyles.body(color: AppColors.textLight),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardWhite,
        selectedItemColor: AppColors.roseGold,
        unselectedItemColor: AppColors.textLight,
        elevation: 0,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    final tt = TextTheme(
      displayLarge:
          AppTextStyles.display(fontSize: 32, color: AppColors.darkTextPrimary),
      displayMedium:
          AppTextStyles.display(fontSize: 26, color: AppColors.darkTextPrimary),
      displaySmall:
          AppTextStyles.display(fontSize: 22, color: AppColors.darkTextPrimary),
      headlineLarge:
          AppTextStyles.heading(fontSize: 22, color: AppColors.darkTextPrimary),
      headlineMedium:
          AppTextStyles.heading(fontSize: 18, color: AppColors.darkTextPrimary),
      headlineSmall:
          AppTextStyles.heading(fontSize: 16, color: AppColors.darkTextPrimary),
      titleLarge: AppTextStyles.body(
        fontSize: 16,
        color: AppColors.darkTextPrimary,
        weight: FontWeight.w700,
      ),
      titleMedium: AppTextStyles.body(
        fontSize: 14,
        color: AppColors.darkTextPrimary,
        weight: FontWeight.w600,
      ),
      titleSmall: AppTextStyles.body(
        fontSize: 13,
        color: AppColors.darkTextPrimary,
        weight: FontWeight.w600,
      ),
      bodyLarge:
          AppTextStyles.body(fontSize: 15, color: AppColors.darkTextSecondary),
      bodyMedium:
          AppTextStyles.body(fontSize: 13, color: AppColors.darkTextSecondary),
      bodySmall:
          AppTextStyles.body(fontSize: 11, color: AppColors.darkTextTertiary),
      labelLarge:
          AppTextStyles.label(fontSize: 14, color: AppColors.darkTextPrimary),
      labelMedium:
          AppTextStyles.label(fontSize: 12, color: AppColors.darkTextSecondary),
      labelSmall:
          AppTextStyles.label(fontSize: 10, color: AppColors.darkTextTertiary),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.nclGasdrifo,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkAccentPink,
        brightness: Brightness.dark,
        surface: AppColors.darkSurface,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: tt,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: AppColors.darkCard,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkAccentPink,
          foregroundColor: AppColors.darkBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTextStyles.button(color: AppColors.darkBackground),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide:
              const BorderSide(color: AppColors.darkAccentPink, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: AppTextStyles.body(color: AppColors.darkTextTertiary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkCard,
        selectedItemColor: AppColors.darkAccentPink,
        unselectedItemColor: AppColors.darkTextTertiary,
        elevation: 0,
      ),
    );
  }

  // Legacy getter for backwards compatibility
  static ThemeData get theme => lightTheme;
}

// Extension to easily get theme-aware colors
extension ThemeAwareColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get textPrimary =>
      isDark ? AppColors.darkTextPrimary : AppColors.textDark;
  Color get textSecondary =>
      isDark ? AppColors.darkTextSecondary : AppColors.textMedium;
  Color get textTertiary =>
      isDark ? AppColors.darkTextTertiary : AppColors.textLight;
  Color get cardColor => isDark ? AppColors.darkCard : AppColors.cardWhite;
  Color get surfaceColor =>
      isDark ? AppColors.darkSurface : AppColors.softWhite;
  Color get accentPink =>
      isDark ? AppColors.darkAccentPink : AppColors.babyPink;
  Color get accentLavender =>
      isDark ? AppColors.darkAccentLavender : AppColors.lilac;

  LinearGradient get gradientBackground =>
      isDark ? AppColors.gradientBackgroundDark : AppColors.gradientBackground;
  LinearGradient get gradientPink =>
      isDark ? AppColors.gradientPinkDark : AppColors.gradientPink;
  LinearGradient get gradientNewPink => AppColors.gradientNewPink;
  LinearGradient get gradientLavender =>
      isDark ? AppColors.gradientLavenderDark : AppColors.gradientLavender;
  LinearGradient get gradientMint =>
      isDark ? AppColors.gradientMintDark : AppColors.gradientMint;
  LinearGradient get gradientPeach =>
      isDark ? AppColors.gradientPeachDark : AppColors.gradientPeach;
}
