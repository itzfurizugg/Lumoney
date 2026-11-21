import 'package:material_ui/material_ui.dart';

class AppColors {
  AppColors._();

  static const Color seed = Color(0xFF006A60);
  static const Color primary = Color(0xFF006A60);
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFF74F8E5);
  static const Color secondary = Color(0xFF4A635F);
  static const Color tertiary = Color(0xFF456179);
  static const Color surface = Color(0xFFF4FBF8);
  static const Color surfaceContainer = Color(0xFFE9EFEC);
  static const Color surfaceContainerHigh = Color(0xFFE3EAE7);
  static const Color onSurface = Color(0xFF161D1C);
  static const Color onSurfaceVariant = Color(0xFF3F4947);
  static const Color outline = Color(0xFF6F7977);
  static const Color income = Color(0xFF1B6B3A);
  static const Color expense = Color(0xFFBA1A1A);
  static const Color transfer = Color(0xFF006A60);

  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color divider = Color(0xFFBFC9C6);
  static const Color background = surface;
}

class AppTheme {
  AppTheme._();

  static ThemeData light({Color seed = AppColors.seed}) => _build(Brightness.light, seed);
  static ThemeData dark({Color seed = AppColors.seed}) => _build(Brightness.dark, seed);

  static ThemeData _build(Brightness brightness, Color seed) {
    final colorScheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      visualDensity: VisualDensity.standard,
    );

    final baseTextTheme = base.textTheme.apply(
      fontFamily: 'GoogleSansFlex',
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );
    final textTheme = baseTextTheme.copyWith(
      displaySmall: baseTextTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.25),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 32),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, fontSize: 28),
      titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 24),
      titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 18),
      titleSmall: baseTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: baseTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );

    return base.copyWith(
      textTheme: textTheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant);
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
          visualDensity: VisualDensity.standard,
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant.withValues(alpha: 0.5), thickness: 1),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
    );
  }
}
