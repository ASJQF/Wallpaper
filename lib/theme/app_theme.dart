import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF07070C);
  static const surface = Color(0xFF12121A);
  static const surfaceHigh = Color(0xFF1C1C28);
  static const violet = Color(0xFF8B5CF6);
  static const neon = Color(0xFF22D3EE);
  static const like = Color(0xFFFF4D8D);
  static const text = Color(0xFFF5F3FF);
  static const muted = Color(0xFFA29BB8);

  static const lightBg = Color(0xFFF6F4FB);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF16141F);
  static const lightMuted = Color(0xFF6E6880);

  static const brandGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF7C3AED), Color(0xFF22D3EE)],
  );
}

class AppTheme {
  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData light() => _theme(Brightness.light);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final bg = dark ? AppColors.bg : AppColors.lightBg;
    final surface = dark ? AppColors.surface : AppColors.lightSurface;
    final text = dark ? AppColors.text : AppColors.lightText;
    final muted = dark ? AppColors.muted : AppColors.lightMuted;
    final outline = dark ? const Color(0x22FFFFFF) : const Color(0x14000000);
    final cairo = GoogleFonts.cairoTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(bodyColor: text, displayColor: text);
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: outline),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      hintColor: muted,
      splashFactory: InkRipple.splashFactory,
      colorScheme: (dark ? const ColorScheme.dark() : const ColorScheme.light())
          .copyWith(
            primary: AppColors.violet,
            onPrimary: Colors.white,
            secondary: AppColors.neon,
            onSecondary: AppColors.bg,
            surface: surface,
            onSurface: text,
            error: AppColors.like,
            onError: Colors.white,
            outline: outline,
          ),
      textTheme: cairo,
      appBarTheme: AppBarThemeData(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: text,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: Colors.transparent,
        indicatorColor: AppColors.violet.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.violet : muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.violet : muted,
            size: 24,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? AppColors.surfaceHigh : AppColors.lightText,
        contentTextStyle: GoogleFonts.cairo(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: text,
        ),
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 14,
          height: 1.6,
          color: text,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.violet,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(64, 52),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: surface,
        hintStyle: GoogleFonts.cairo(color: muted, fontSize: 14),
        prefixIconColor: muted,
        suffixIconColor: muted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.violet, width: 1.4),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: AppColors.violet,
        labelStyle: GoogleFonts.cairo(color: text, fontWeight: FontWeight.w700),
        secondaryLabelStyle: GoogleFonts.cairo(color: text),
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      ),
      dividerTheme: DividerThemeData(color: outline),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
