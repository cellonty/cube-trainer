import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'services/settings_service.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final settings = SettingsService();
  final isDark = await settings.getTheme();
  final langCode = await settings.getLanguage();

  runApp(MyApp(
    initialDark: isDark,
    initialLocale: Locale(langCode),
  ));
}

class MyApp extends StatefulWidget {
  final bool initialDark;
  final Locale initialLocale;
  const MyApp({
    Key? key,
    required this.initialDark,
    required this.initialLocale,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDark;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _isDark = widget.initialDark;
    _locale = widget.initialLocale;
  }

  Future<void> _toggleTheme(bool value) async {
    setState(() => _isDark = value);
    await SettingsService().saveTheme(value);
  }

  void _setLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cube Trainer',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(
        isDark: _isDark,
        onThemeChanged: _toggleTheme,
        currentLocale: _locale,
        onLocaleChanged: _setLocale,
      ),
    );
  }
}