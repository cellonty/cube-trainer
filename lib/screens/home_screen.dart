import 'package:flutter/material.dart';
import 'training_screen.dart';
import 'settings_screen.dart';
import '../data/alg_database.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  const HomeScreen({
    Key? key,
    required this.isDark,
    required this.onThemeChanged,
    required this.currentLocale,
    required this.onLocaleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsScreen(
                  isDark: isDark,
                  onThemeChanged: onThemeChanged,
                  currentLocale: currentLocale,
                  onLocaleChanged: onLocaleChanged,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),

            const _Header(title: 'CFOP'),
            const SizedBox(height: 8),

            _SectionCard(
              title: 'F2L',
              subtitle: t.f2lSubtitle,
              description: t.f2lDesc,
              count: AlgDatabase.f2l.length,
              icon: Icons.link_rounded,
              color: const Color(0xFF00B84A),
              onTap: () => _open(context, 'F2L', AlgDatabase.f2l),
            ),
            const SizedBox(height: 12),

            _SectionCard(
              title: 'OLL',
              subtitle: t.ollSubtitle,
              description: t.ollDesc,
              count: AlgDatabase.oll.length,
              icon: Icons.grid_on_rounded,
              color: const Color(0xFFFFB300),
              onTap: () => _open(context, 'OLL', AlgDatabase.oll),
            ),
            const SizedBox(height: 12),

            _SectionCard(
              title: 'PLL',
              subtitle: t.pllSubtitle,
              description: t.pllDesc,
              count: AlgDatabase.pll.length,
              icon: Icons.grid_view_rounded,
              color: const Color(0xFFD50000),
              onTap: () => _open(context, 'PLL', AlgDatabase.pll),
            ),

            const SizedBox(height: 24),

            const _Header(title: 'Roux'),
            const SizedBox(height: 8),

            _SectionCard(
              title: 'CMLL',
              subtitle: t.cmllSubtitle,
              description: t.cmllDesc,
              count: AlgDatabase.rouxCMLL.length,
              icon: Icons.grid_on_rounded,
              color: const Color(0xFF7B1FA2),
              onTap: () => _open(context, 'CMLL', AlgDatabase.rouxCMLL),
            ),
            const SizedBox(height: 12),

            _SectionCard(
              title: 'LSE',
              subtitle: t.lseSubtitle,
              description: t.lseDesc,
              count: AlgDatabase.rouxLSE.length,
              icon: Icons.swap_horiz_rounded,
              color: const Color(0xFF00897B),
              onTap: () => _open(context, 'LSE', AlgDatabase.rouxLSE),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, String title, List<dynamic> algorithms) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrainingScreen(title: title, algorithms: algorithms),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      shadowColor: color.withOpacity(0.3),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}