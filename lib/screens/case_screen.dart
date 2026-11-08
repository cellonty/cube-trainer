import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../logic/alg_tools.dart';
import '../logic/scramble.dart';
import '../logic/stats.dart';
import '../models/alg_models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/alg_player.dart';
import '../widgets/common.dart';

class CaseScreen extends StatefulWidget {
  final AlgCase algCase;
  const CaseScreen({super.key, required this.algCase});

  @override
  State<CaseScreen> createState() => _CaseScreenState();
}

class _CaseScreenState extends State<CaseScreen> {
  late final TextEditingController _note;
  String _scramble = '';

  AlgCase get c => widget.algCase;

  @override
  void initState() {
    super.initState();
    _note = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scramble.isEmpty) {
      final state = AppScope.read(context);
      _note.text = state.note(c.id);
      _newScramble(state);
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _newScramble(AppState state) {
    final main = state.mainAlg(c);
    _scramble = Scrambler.forCase(c.scrambles, c.scrambleFrom, c.algs.indexOf(main));
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).tr('copied'))));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context);
    final th = Theme.of(context);
    final set = AlgRepo.setOfCase[c.id]!;
    final color = AppTheme.colorForSet(set.id);
    final main = state.mainAlg(c);
    final custom = state.customAlgs(c.id);
    final fav = state.isFavorite(c.id);
    final times = state.times(c.id);
    final playerSize = math.min(MediaQuery.sizeOf(context).width - 72, 320.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(c.title),
        actions: [
          IconButton(
            tooltip: t.tr('favorites'),
            onPressed: () => state.toggleFavorite(c.id),
            icon: Icon(fav ? Icons.star_rounded : Icons.star_outline_rounded,
                color: fav ? const Color(0xFFFFC107) : null),
          ),
          IconButton(tooltip: t.tr('copy'), onPressed: () => _copy(main), icon: const Icon(Icons.copy_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            CountPill(color: color, icon: Icons.layers_rounded, text: set.title),
            CountPill(color: th.colorScheme.secondary, icon: Icons.category_rounded, text: c.group),
            StatusPill(status: state.status(c.id)),
          ]),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: AlgPlayer(
                setup: c.setup,
                alg: main,
                twoByTwo: c.goal.isTwoByTwo,
                goal: c.goal,
                grayscale: state.grayscale,
                size: playerSize,
              ),
            ),
          ),
          SectionHeader(title: t.tr('status'), padding: const EdgeInsets.fromLTRB(4, 22, 4, 10)),
          SegmentedButton<LearnStatus>(
            showSelectedIcon: false,
            segments: [
              for (final s in LearnStatus.values)
                ButtonSegment(value: s, icon: Icon(statusIcon(s), size: 18), label: Text(statusLabel(t, s))),
            ],
            selected: {state.status(c.id)},
            onSelectionChanged: (s) => state.setStatus(c.id, s.first),
          ),
          SectionHeader(
            title: '${t.tr('algorithms')} (${c.algs.length + custom.length})',
            subtitle: t.tr('algs_hint'),
            padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
          ),
          for (var i = 0; i < c.algs.length; i++)
            _AlgTile(
              alg: c.algs[i],
              source: i < c.sources.length ? c.sources[i] : '',
              selected: c.algs[i] == main,
              color: color,
              onTap: () => state.setMainAlg(c.id, c.algs[i]),
              onCopy: () => _copy(c.algs[i]),
            ),
          for (final a in custom)
            _AlgTile(
              alg: a,
              source: t.tr('custom_alg'),
              selected: a == main,
              color: color,
              onTap: () => state.setMainAlg(c.id, a),
              onCopy: () => _copy(a),
              onDelete: () => state.removeCustomAlg(c.id, a),
            ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () => _addCustom(context),
            icon: const Icon(Icons.add_rounded),
            label: Text(t.tr('add_custom_alg')),
          ),
          SectionHeader(title: t.tr('practice_scramble'), padding: const EdgeInsets.fromLTRB(4, 22, 4, 10)),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
              child: Row(children: [
                Expanded(
                  child: SelectableText(_scramble, style: AppTheme.mono.copyWith(fontSize: 16, height: 1.4)),
                ),
                IconButton(
                  tooltip: t.tr('new_scramble'),
                  onPressed: () => setState(() => _newScramble(state)),
                  icon: const Icon(Icons.refresh_rounded),
                ),
                IconButton(tooltip: t.tr('copy'), onPressed: () => _copy(_scramble), icon: const Icon(Icons.copy_rounded)),
              ]),
            ),
          ),
          SectionHeader(
            title: t.tr('your_times'),
            padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
            trailing: times.isEmpty
                ? null
                : TextButton(onPressed: () => state.clearTimes(c.id), child: Text(t.tr('reset'))),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: times.isEmpty
                  ? Text(t.tr('no_times_yet'), style: th.textTheme.bodyMedium?.copyWith(color: th.colorScheme.onSurfaceVariant))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _MiniStat(label: t.tr('best'), value: Stats.format(times.reduce(math.min))),
                        _MiniStat(label: t.tr('average'), value: Stats.format(state.avgTime(c.id)?.round())),
                        _MiniStat(label: t.tr('attempts'), value: '${times.length}'),
                      ],
                    ),
            ),
          ),
          SectionHeader(title: t.tr('notes'), padding: const EdgeInsets.fromLTRB(4, 22, 4, 10)),
          TextField(
            controller: _note,
            minLines: 3,
            maxLines: 8,
            onChanged: (v) => state.setNote(c.id, v),
            decoration: InputDecoration(hintText: t.tr('notes_hint')),
          ),
        ],
      ),
    );
  }

  Future<void> _addCustom(BuildContext context) async {
    final state = AppScope.read(context);
    final t = AppLocalizations.of(context);
    final ctl = TextEditingController();
    String? error;
    final added = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(t.tr('add_custom_alg')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.tr('custom_alg_desc'), style: Theme.of(ctx).textTheme.bodySmall),
              const SizedBox(height: 12),
              TextField(
                controller: ctl,
                autofocus: true,
                style: AppTheme.mono,
                decoration: InputDecoration(hintText: "R U R' U'", errorText: error, errorMaxLines: 3),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.tr('cancel'))),
            FilledButton(
              onPressed: () {
                final alg = AlgTools.clean(ctl.text);
                if (alg.isEmpty) return;
                final bad = AlgTools.invalidToken(alg, twoByTwo: c.goal.isTwoByTwo);
                if (bad != null) {
                  setD(() => error = t.tr('err_token').replaceAll('{t}', bad));
                  return;
                }
                if (c.algs.contains(alg) || state.customAlgs(c.id).contains(alg)) {
                  setD(() => error = t.tr('err_exists'));
                  return;
                }
                if (!CubeChecks.solves(c.setup, alg, c.goal)) {
                  setD(() => error = t.tr('err_not_solving'));
                  return;
                }
                Navigator.pop(ctx, alg);
              },
              child: Text(t.tr('verify_add')),
            ),
          ],
        ),
      ),
    );
    ctl.dispose();
    if (added != null && mounted) {
      state.addCustomAlg(c.id, added);
      ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text(t.tr('alg_added'))));
    }
  }
}

class _AlgTile extends StatelessWidget {
  final String alg;
  final String source;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onCopy;
  final VoidCallback? onDelete;

  const _AlgTile({
    required this.alg,
    required this.source,
    required this.selected,
    required this.color,
    required this.onTap,
    required this.onCopy,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : th.cardTheme.color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color : th.colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Row(
              children: [
                Icon(selected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: selected ? color : th.colorScheme.onSurfaceVariant),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(alg, style: AppTheme.mono.copyWith(fontSize: 15.5, height: 1.35)),
                      const SizedBox(height: 4),
                      Text(
                        '$source · ${AlgTools.moveCount(alg)} ${t.tr('moves')}${selected ? ' · ${t.tr('main_alg')}' : ''}',
                        style: th.textTheme.labelSmall?.copyWith(color: th.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: onCopy, icon: const Icon(Icons.copy_rounded, size: 18)),
                if (onDelete != null)
                  IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded, size: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Column(children: [
      Text(value, style: th.textTheme.titleLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
      const SizedBox(height: 2),
      Text(label, style: th.textTheme.labelSmall?.copyWith(color: th.colorScheme.onSurfaceVariant)),
    ]);
  }
}
