import 'package:flutter/material.dart';
import '../services/scramble_generator.dart';
import '../services/settings_service.dart';
import '../models/rubiks_cube.dart';
import '../widgets/cube_preview_3d.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  const SettingsScreen({
    Key? key,
    required this.isDark,
    required this.onThemeChanged,
    required this.currentLocale,
    required this.onLocaleChanged,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isDark = widget.isDark;
  final _cube = RubiksCube();
  final _moveController = TextEditingController();
  String _lastScramble = '';
  String _history = '';

  void _doScramble() {
    final s = ScrambleGenerator.generate(20);
    _cube.applyScramble(s);
    setState(() {
      _lastScramble = s;
      _history = '';
    });
  }

  void _reset() {
    _cube.f['U'] = List.filled(9, 'Y');
    _cube.f['D'] = List.filled(9, 'W');
    _cube.f['L'] = List.filled(9, 'R');
    _cube.f['R'] = List.filled(9, 'O');
    _cube.f['F'] = List.filled(9, 'G');
    _cube.f['B'] = List.filled(9, 'B');
    setState(() {
      _lastScramble = '';
      _history = '';
    });
  }

  void _applyMoves() {
    final text = _moveController.text.trim();
    if (text.isEmpty) return;
    _cube.applyScramble(text);
    setState(() {
      _history = text;
    });
  }

  Future<void> _openLanguagePicker() async {
    final t = AppLocalizations.of(context);
    final selected = await showDialog<Locale>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text(t.selectLanguage),
          children: AppLocalizations.supportedLocales.map((locale) {
            final code = locale.languageCode;
            final name = AppLocalizations.languageNames[code] ?? code;
            return RadioListTile<String>(
              value: code,
              groupValue: widget.currentLocale.languageCode,
              title: Text(name),
              onChanged: (v) {
                Navigator.pop(ctx, Locale(v!));
              },
            );
          }).toList(),
        );
      },
    );
    if (selected != null) {
      widget.onLocaleChanged(selected);
      await SettingsService().saveLanguage(selected.languageCode);
    }
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final currentLangName = AppLocalizations
            .languageNames[widget.currentLocale.languageCode] ??
        widget.currentLocale.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          SwitchListTile(
            title: Text(t.darkMode),
            value: _isDark,
            onChanged: (v) {
              setState(() => _isDark = v);
              widget.onThemeChanged(v);
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(t.language),
            subtitle: Text(currentLangName),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openLanguagePicker,
          ),
          const Divider(),
          ListTile(
            title: Text(
              t.threeDPreview,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: CubePreview3D(cube: _cube, size: 240),
            ),
          ),
          const SizedBox(height: 12),
          if (_lastScramble.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.scrambleLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    _lastScramble,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          if (_history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    t.appliedLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    _history,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _doScramble,
                icon: const Icon(Icons.shuffle),
                label: Text(t.scrambleButton),
              ),
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: Text(t.reset),
              ),
            ],
          ),
          const Divider(height: 32),
          ListTile(
            title: Text(
              t.applyCustomMoves,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(t.applyCustomMovesHint),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _moveController,
                    style: const TextStyle(fontFamily: 'monospace'),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "R U R' U'",
                      isDense: true,
                    ),
                    onSubmitted: (_) => _applyMoves(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyMoves,
                  child: Text(t.apply),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}