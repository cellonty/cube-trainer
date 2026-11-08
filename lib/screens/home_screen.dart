import 'package:flutter/material.dart';

import '../data/alg_data.dart';
import '../l10n/app_localizations.dart';
import '../models/alg_models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/cube_3d.dart';
import 'case_screen.dart';
import 'set_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context);
    final favs = [
      for (final s in kAlgSets)
        for (final c in s.cases)
          if (state.isFavorite(c.id)) c,
    ];

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SafeArea(bottom: false, child: _Hero(state: state))),
        if (favs.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SectionHeader(title: '★ ${t.tr('favorites')}', subtitle: '${favs.length}'),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 150,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: favs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final c = favs[i];
                  final set = AlgRepo.setOfCase[c.id]!;
                  return SizedBox(
                    width: 120,
                    child: TintCard(
                      color: AppTheme.colorForSet(set.id),
                      padding: const EdgeInsets.all(10),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => CaseScreen(algCase: c)),
                      ),
                      child: Column(
                        children: [
                          Expanded(child: CasePreview(algCase: c, size: 90, grayscale: state.grayscale)),
                          const SizedBox(height: 6),
                          Text(c.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        for (final m in Method.values) ...[
          SliverToBoxAdapter(
            child: SectionHeader(title: methodName(t, m), subtitle: t.tr('method_${m.name}_sub')),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 340,
                mainAxisExtent: 152,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              delegate: SliverChildListDelegate([
                for (final s in AlgRepo.byMethod(m)) _SetTile(set: s),
              ]),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  final AppState state;
  const _Hero({required this.state});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    var learned = 0, learning = 0;
    for (final s in kAlgSets) {
      learned += state.countStatus(s, LearnStatus.learned);
      learning += state.countStatus(s, LearnStatus.learning);
    }
    final progress = kTotalCases == 0 ? 0.0 : learned / kTotalCases;
    const white = Colors.white;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.fromLTRB(22, 20, 12, 20),
      decoration: BoxDecoration(
        gradient: AppTheme.hero(scheme),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: scheme.primary.withValues(alpha: 0.35), blurRadius: 30, offset: const Offset(0, 12)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.tr('app_title'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: white)),
                const SizedBox(height: 4),
                Text(
                  t.tr('hero_subtitle').replaceAll('{cases}', '$kTotalCases').replaceAll('{algs}', '$kTotalAlgs'),
                  style: TextStyle(color: white.withValues(alpha: 0.85), fontSize: 13, height: 1.3),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Text('${(progress * 100).round()}%',
                      style: const TextStyle(color: white, fontSize: 30, fontWeight: FontWeight.w900, height: 1)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t.tr('learned_of').replaceAll('{n}', '$learned').replaceAll('{total}', '$kTotalCases'),
                      style: TextStyle(color: white.withValues(alpha: 0.9), fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(children: [
                    Container(height: 8, color: white.withValues(alpha: 0.22)),
                    FractionallySizedBox(
                      widthFactor: (learned + learning) / (kTotalCases == 0 ? 1 : kTotalCases),
                      child: Container(height: 8, color: white.withValues(alpha: 0.45)),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(height: 8, color: white),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                Text(
                  t.tr('learning_now').replaceAll('{n}', '$learning'),
                  style: TextStyle(color: white.withValues(alpha: 0.8), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const SpinningCube(size: 118),
        ],
      ),
    );
  }
}

class _SetTile extends StatelessWidget {
  final AlgSet set;
  const _SetTile({required this.set});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context);
    final th = Theme.of(context);
    final color = AppTheme.colorForSet(set.id);
    final learned = state.countStatus(set, LearnStatus.learned);
    final learning = state.countStatus(set, LearnStatus.learning);
    final total = set.cases.length;
    final algs = set.cases.fold<int>(0, (a, c) => a + c.algs.length);

    return TintCard(
      color: color,
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SetScreen(set: set))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(set.title, style: th.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(
                      t.tr('set_${set.id}'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: th.textTheme.bodySmall?.copyWith(color: th.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              ProgressRing(
                value: total == 0 ? 0 : learned / total,
                color: color,
                size: 46,
                stroke: 5,
                child: Text('${total == 0 ? 0 : (learned * 100 / total).round()}%',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color)),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: CasePreview(algCase: set.cases.first, size: 42, grayscale: state.grayscale),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.tr('n_cases_algs').replaceAll('{c}', '$total').replaceAll('{a}', '$algs'),
                      style: th.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(children: [
                        Container(height: 5, color: color.withValues(alpha: 0.16)),
                        FractionallySizedBox(
                          widthFactor: total == 0 ? 0 : (learned + learning) / total,
                          child: Container(height: 5, color: AppTheme.statusLearning.withValues(alpha: 0.8)),
                        ),
                        FractionallySizedBox(
                          widthFactor: total == 0 ? 0 : learned / total,
                          child: Container(height: 5, color: color),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
