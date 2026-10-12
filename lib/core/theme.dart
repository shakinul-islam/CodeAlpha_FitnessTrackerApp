import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color bgColor = Color(0xFF07111F);
  static const Color surfaceColor = Color(0xFF0D1B2A);
  static const Color cardColor = Color(0xFF122235);
  static const Color cardColorSoft = Color(0xFF172A3E);

  static const Color accentColor = Color(0xFF19D3C5);
  static const Color purpleAccent = Color(0xFF8B5CF6);
  static const Color orangeAccent = Color(0xFFFF9F43);
  static const Color dangerColor = Color(0xFFFF5C7A);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.dark,
      surface: surfaceColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgColor,

      colorScheme: colorScheme.copyWith(
        primary: accentColor,
        secondary: purpleAccent,
        surface: surfaceColor,
        error: dangerColor,
      ),

      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: surfaceColor,
        indicatorColor: accentColor.withOpacity(.16),

        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);

          return GoogleFonts.poppins(
            color: selected ? accentColor : textSecondary,
            fontSize: 12,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.w500,
          );
        }),

        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);

          return IconThemeData(
            color: selected ? accentColor : textSecondary,
            size: 24,
          );
        }),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,

        labelStyle: const TextStyle(
          color: textSecondary,
        ),

        hintStyle: TextStyle(
          color: textSecondary.withOpacity(.65),
        ),

        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(.05),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: accentColor,
            width: 1.2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: dangerColor,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: accentColor,
          foregroundColor: const Color(0xFF041615),
          elevation: 0,

          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        margin: EdgeInsets.zero,
        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardColorSoft,

        contentTextStyle: GoogleFonts.poppins(
          color: textPrimary,
        ),

        behavior: SnackBarBehavior.floating,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  static BoxDecoration premiumCard({
    Color? borderColor,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      gradient: gradient,
      color: gradient == null ? cardColor : null,

      borderRadius: BorderRadius.circular(24),

      border: Border.all(
        color: borderColor ??
            Colors.white.withOpacity(.06),
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.20),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    );
  }
}