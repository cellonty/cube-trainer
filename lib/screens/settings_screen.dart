import 'package:flutter/material.dart';

import '../data/alg_data.dart';
import '../l10n/app_localizations.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context);
    final th = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
            child: Text(t.tr('settings'), style: th.textTheme.headlineMedium),
          ),
          SectionHeader(title: t.tr('appearance'), padding: const EdgeInsets.fromLTRB(4, 16, 4, 8)),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.tr('theme'), style: th.textTheme.titleSmall),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                            value: ThemeMode.system,
                            icon: const Icon(Icons.brightness_auto_rounded),
                            label: Text(t.tr('theme_system'))),
                        ButtonSegment(
                            value: ThemeMode.light,
                            icon: const Icon(Icons.light_mode_rounded),
                            label: Text(t.tr('theme_light'))),
                        ButtonSegment(
                            value: ThemeMode.dark,
                            icon: const Icon(Icons.dark_mode_rounded),
                            label: Text(t.tr('theme_dark'))),
                      ],
                      selected: {state.themeMode},
                      onSelectionChanged: (s) => state.setThemeMode(s.first),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(t.tr('accent'), style: th.textTheme.titleSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (var i = 0; i < AppTheme.accents.length; i++)
                        GestureDetector(
                          onTap: () => state.setAccent(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.accents[i],
                                  Color.lerp(AppTheme.accents[i], Colors.black, 0.25)!,
                                ],
                              ),
                              border: Border.all(
                                color: state.accent == i ? th.colorScheme.onSurface : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accents[i].withValues(alpha: state.accent == i ? 0.5 : 0.2),
                                  blurRadius: state.accent == i ? 14 : 6,
                                ),
                              ],
                            ),
                            child: state.accent == i
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                                : null,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(title: t.tr('language'), padding: const EdgeInsets.fromLTRB(4, 20, 4, 8)),
          Card(
            child: ListTile(
              leading: const Icon(Icons.translate_rounded),
              title: Text(AppLocalizations.languageNames[state.language] ?? state.language),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _pickLanguage(context),
            ),
          ),
          SectionHeader(title: t.tr('training'), padding: const EdgeInsets.fromLTRB(4, 20, 4, 8)),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.filter_b_and_w_rounded),
                  title: Text(t.tr('grayscale')),
                  subtitle: Text(t.tr('grayscale_desc')),
                  value: state.grayscale,
                  onChanged: state.setGrayscale,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  secondary: const Icon(Icons.visibility_rounded),
                  title: Text(t.tr('inspection')),
                  subtitle: Text(t.tr('inspection_desc')),
                  value: state.inspection,
                  onChanged: state.setInspection,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.touch_app_rounded),
                  title: Text(t.tr('hold_time')),
                  subtitle: Slider(
                    value: state.holdMs.toDouble().clamp(100, 800),
                    min: 100,
                    max: 800,
                    divisions: 14,
                    label: '${state.holdMs} ms',
                    onChanged: (v) => state.setHoldMs(v.round()),
                  ),
                  trailing: Text('${state.holdMs} ms', style: th.textTheme.labelLarge),
                ),
              ],
            ),
          ),
          SectionHeader(title: t.tr('about'), padding: const EdgeInsets.fromLTRB(4, 20, 4, 8)),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.verified_rounded, color: AppTheme.statusLearned),
                  title: Text(t.tr('cases_algs').replaceAll('{c}', '$kTotalCases').replaceAll('{a}', '$kTotalAlgs')),
                  subtitle: Text(t.tr('verified_desc')),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.menu_book_rounded),
                  title: Text(t.tr('sources')),
                  subtitle: const Text(
                      'SpeedCubeDB (speedcubedb.com) · CubeSkills (OLL) · Kian Mansour & Bradley K. Hobbs (CMLL / LSE)'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                const ListTile(
                  leading: Icon(Icons.code_rounded),
                  title: Text('Cube Trainer'),
                  subtitle: Text('github.com/cellonty/cube-trainer · MIT'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _pickLanguage(BuildContext context) {
    final state = AppScope.read(context);
    final t = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(t.tr('language'), style: Theme.of(ctx).textTheme.titleLarge),
            ),
            for (final code in AppLocalizations.supportedCodes)
              ListTile(
                title: Text(AppLocalizations.languageNames[code] ?? code),
                trailing: code == state.language
                    ? Icon(Icons.check_rounded, color: Theme.of(ctx).colorScheme.primary)
                    : null,
                onTap: () {
                  state.setLanguage(code);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }
}
