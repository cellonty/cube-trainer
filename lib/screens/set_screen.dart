import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../logic/stats.dart';
import '../models/alg_models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'case_screen.dart';
import 'trainer_screen.dart';

class SetScreen extends StatefulWidget {
  final AlgSet set;
  const SetScreen({super.key, required this.set});

  @override
  State<SetScreen> createState() => _SetScreenState();
}

class _SetScreenState extends State<SetScreen> {
  String _query = '';
  String _filter = 'all';

  bool _matches(AppState state, AlgCase c) {
    switch (_filter) {
      case 'new':
        if (state.status(c.id) != LearnStatus.notLearned) return false;
      case 'learning':
        if (state.status(c.id) != LearnStatus.learning) return false;
      case 'learned':
        if (state.status(c.id) != LearnStatus.learned) return false;
      case 'fav':
        if (!state.isFavorite(c.id)) return false;
    }
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return c.title.toLowerCase().contains(q) ||
        c.group.toLowerCase().contains(q) ||
        c.id.toLowerCase().contains(q) ||
        c.algs.any((a) => a.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context);
    final th = Theme.of(context);
    final set = widget.set;
    final color = AppTheme.colorForSet(set.id);
    final visible = set.cases.where((c) => _matches(state, c)).toList();

    final filters = <(String, String)>[
      ('all', t.tr('filter_all')),
      ('new', t.tr('status_new')),
      ('learning', t.tr('status_learning')),
      ('learned', t.tr('status_learned')),
      ('fav', '★ ${t.tr('favorites')}'),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(set.title),
            actions: [
              IconButton(
                tooltip: t.tr('train_set'),
                icon: const Icon(Icons.bolt_rounded),
                onPressed: () => _train(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.tr('set_${set.id}'),
                      style: th.textTheme.bodyMedium?.copyWith(color: th.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    CountPill(
                      color: AppTheme.statusLearned,
                      icon: Icons.check_circle_rounded,
                      text: '${state.countStatus(set, LearnStatus.learned)} ${t.tr('status_learned').toLowerCase()}',
                    ),
                    CountPill(
                      color: AppTheme.statusLearning,
                      icon: Icons.timelapse_rounded,
                      text: '${state.countStatus(set, LearnStatus.learning)} ${t.tr('status_learning').toLowerCase()}',
                    ),
                    CountPill(
                      color: color,
                      icon: Icons.layers_rounded,
                      text: '${set.cases.length} ${t.tr('cases')}',
                    ),
                  ]),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (v) => setState(() => _query = v.trim()),
                    decoration: InputDecoration(
                      hintText: t.tr('search_hint'),
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      for (final (id, label) in filters)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(label),
                            selected: _filter == id,
                            onSelected: (_) => setState(() => _filter = id),
                          ),
                        ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
          if (visible.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.search_off_rounded, size: 48, color: th.colorScheme.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text(t.tr('no_algorithms'), textAlign: TextAlign.center),
                  ]),
                ),
              ),
            ),
          for (final g in set.groups) ...() {
            final cases = visible.where((c) => c.group == g).toList();
            if (cases.isEmpty) return <Widget>[];
            return <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                  child: Row(children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(g, style: th.textTheme.titleMedium)),
                    Text('${cases.length}',
                        style: th.textTheme.labelLarge?.copyWith(color: th.colorScheme.onSurfaceVariant)),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisExtent: 244,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => CaseCard(algCase: cases[i], color: color),
                    childCount: cases.length,
                  ),
                ),
              ),
            ];
          }(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _train(context),
        icon: const Icon(Icons.bolt_rounded),
        label: Text(t.tr('train_set')),
      ),
    );
  }

  void _train(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TrainerScreen(initialSets: {widget.set.id}, standalone: true),
    ));
  }
}

class CaseCard extends StatelessWidget {
  final AlgCase algCase;
  final Color color;
  const CaseCard({super.key, required this.algCase, required this.color});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context);
    final th = Theme.of(context);
    final c = algCase;
    final status = state.status(c.id);
    final fav = state.isFavorite(c.id);
    final avg = state.avgTime(c.id);

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CaseScreen(algCase: c))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 126,
              decoration: BoxDecoration(gradient: AppTheme.tile(color, th.brightness)),
              child: Stack(
                children: [
                  Center(child: CasePreview(algCase: c, size: 108, grayscale: state.grayscale)),
                  Positioned(left: 10, top: 10, child: StatusPill(status: status, compact: true)),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => state.toggleFavorite(c.id),
                      icon: Icon(
                        fav ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: fav ? const Color(0xFFFFC107) : th.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: th.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(
                    state.mainAlg(c),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.mono.copyWith(fontSize: 12, height: 1.35, color: th.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.alt_route_rounded, size: 14, color: th.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Text('${c.algs.length + state.customAlgs(c.id).length}',
                        style: th.textTheme.labelSmall?.copyWith(color: th.colorScheme.onSurfaceVariant)),
                    const Spacer(),
                    if (avg != null)
                      Text(
                        '⏱ ${Stats.format(avg.round())}',
                        style: th.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800, color: color),
                      )
                    else
                      Text(statusLabel(t, status),
                          style: th.textTheme.labelSmall?.copyWith(color: statusColor(status))),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
