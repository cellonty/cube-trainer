import 'package:flutter/material.dart';

class AppTheme {
  static const List<Color> accents = [
    Color(0xFF7C5CFF), // violet
    Color(0xFF00BFA6), // teal
    Color(0xFF2F80ED), // blue
    Color(0xFFFF7A45), // orange
    Color(0xFFE8457C), // pink
    Color(0xFF2DBE60), // green
  ];

  /// Sticker colours (same letters as RubiksCube).
  static const Map<String, Color> sticker = {
    'W': Color(0xFFF7F8FA),
    'Y': Color(0xFFFFD60A),
    'O': Color(0xFFFF8A00),
    'R': Color(0xFFE5262B),
    'G': Color(0xFF14C25A),
    'B': Color(0xFF1E6BFF),
  };
  static const Color maskedSticker = Color(0xFF6E7380);
  static const Color cubeBody = Color(0xFF15161C);

  /// Accent per algorithm set (tiles, rings).
  static const Map<String, Color> setColor = {
    'f2l': Color(0xFF2F80ED),
    'oll2': Color(0xFFFFB020),
    'oll': Color(0xFFFF9F0A),
    'pll2': Color(0xFF34C759),
    'pll': Color(0xFF2DBE60),
    'coll': Color(0xFFAF52DE),
    'ell': Color(0xFFFF375F),
    'cmll': Color(0xFF5E5CE6),
    'lse': Color(0xFF00BFA6),
    'ortoll': Color(0xFFFF7A45),
    'pbl': Color(0xFFE8457C),
    'cll': Color(0xFF0FB5E8),
    'eg1': Color(0xFF7C5CFF),
    'eg2': Color(0xFFBF5AF2),
  };

  static Color colorForSet(String id) => setColor[id] ?? accents.first;

  static const Color statusNew = Color(0xFF8E93A3);
  static const Color statusLearning = Color(0xFFFFB020);
  static const Color statusLearned = Color(0xFF2DBE60);

  static ThemeData build(int accent, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final seed = accents[accent % accents.length];
    var scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    final bg = dark ? const Color(0xFF0C0D12) : const Color(0xFFF4F5FA);
    final card = dark ? const Color(0xFF171922) : Colors.white;
    scheme = scheme.copyWith(
      surface: bg,
      surfaceContainerLowest: dark ? const Color(0xFF101118) : Colors.white,
      surfaceContainerLow: card,
      surfaceContainer: dark ? const Color(0xFF1C1E28) : const Color(0xFFF0F1F7),
      surfaceContainerHigh: dark ? const Color(0xFF222532) : const Color(0xFFE9EBF3),
      surfaceContainerHighest: dark ? const Color(0xFF2A2D3B) : const Color(0xFFE1E4EE),
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: brightness);
    final text = base.textTheme.copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1.5),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
      titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      titleSmall: base.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      textTheme: text,
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: dark ? const Color(0x14FFFFFF) : const Color(0x0F000000)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        elevation: 0,
        backgroundColor: dark ? const Color(0xFF12131A) : Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: dark ? 0.28 : 0.16),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
              color: states.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
            )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
            )),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        labelStyle: TextStyle(fontWeight: FontWeight.w600, color: scheme.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant.withValues(alpha: 0.35), space: 1),
    );
  }

  static LinearGradient hero(ColorScheme s) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          s.primary,
          Color.lerp(s.primary, s.tertiary, 0.65)!,
          Color.lerp(s.tertiary, Colors.black, 0.1)!,
        ],
      );

  static LinearGradient tile(Color c, Brightness b) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          c.withValues(alpha: b == Brightness.dark ? 0.30 : 0.18),
          c.withValues(alpha: b == Brightness.dark ? 0.08 : 0.04),
        ],
      );

  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontFamilyFallback: ['RobotoMono', 'Menlo', 'Consolas', 'Courier New'],
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}
