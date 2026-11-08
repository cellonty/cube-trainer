import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/alg_data.dart';
import '../l10n/app_localizations.dart';
import '../logic/scramble.dart';
import '../logic/speed_timer.dart';
import '../logic/stats.dart';
import '../models/alg_models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'case_screen.dart';

/// Case trainer: random scramble for a case from the selected sets,
/// weighted towards cases that are slow or still being learned.
class TrainerScreen extends StatefulWidget {
  final Set<String>? initialSets;
  final bool standalone;
  final bool active;
  const TrainerScreen({super.key, this.initialSets, this.standalone = false, this.active = true});

  @override
  State<TrainerScreen> createState() => _TrainerScreenState();
}

class _TrainerScreenState extends State<TrainerScreen> {
  final _rnd = math.Random();
  final _focus = FocusNode(debugLabel: 'trainer');
  late Set<String> _sets;
  Set<LearnStatus> _statuses = LearnStatus.values.toSet();
  bool _favOnly = false;

  AlgCase? _current;
  String _scramble = '';
  bool _hint = false;

  AlgCase? _lastCase;
  int? _lastMs;
  bool _reveal = false;

  final Map<String, int> _seen = {};
  int _round = 0;
  SpeedTimer? _timer;

  static const _statusWeight = {
    LearnStatus.notLearned: 1.0,
    LearnStatus.learning: 3.0,
    LearnStatus.learned: 0.6,
  };

  @override
  void initState() {
    super.initState();
    _sets = {...(widget.initialSets ?? {'oll', 'pll'})};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    if (_timer == null) {
      _timer = SpeedTimer(holdMs: state.holdMs, useInspection: false, onSolved: _onSolved)
        ..addListener(_onTimer);
      _next();
    } else {
      _timer!.holdMs = state.holdMs;
    }
  }

  @override
  void didUpdateWidget(covariant TrainerScreen old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _focus.requestFocus();
    } else if (!widget.active && old.active) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.removeListener(_onTimer);
    _timer?.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onTimer() {
    if (mounted) setState(() {});
  }

  List<AlgCase> _pool(AppState state) => [
        for (final s in kAlgSets)
          if (_sets.contains(s.id))
            for (final c in s.cases)
              if (_statuses.contains(state.status(c.id)) && (!_favOnly || state.isFavorite(c.id))) c,
      ];

  void _next() {
    final state = AppScope.read(context);
    final pool = _pool(state);
    if (pool.isEmpty) {
      _current = null;
      _scramble = '';
      return;
    }
    final avgs = {for (final c in pool) c.id: state.avgTime(c.id)};
    final known = avgs.values.whereType<double>().toList();
    final global = known.isEmpty ? null : known.reduce((a, b) => a + b) / known.length;
    final weights = <double>[];
    for (final c in pool) {
      if (pool.length > 1 && c.id == _current?.id) {
        weights.add(0);
        continue;
      }
      final avg = avgs[c.id];
      final speed = (avg == null || global == null || global == 0) ? 1.5 : (avg / global).clamp(0.5, 3.0);
      final since = math.min(_round - (_seen[c.id] ?? -20), 20);
      weights.add(_statusWeight[state.status(c.id)]! * speed * (1 + 0.15 * since));
    }
    final total = weights.fold<double>(0, (a, b) => a + b);
    var r = _rnd.nextDouble() * total;
    var pick = pool.last;
    for (var i = 0; i < pool.length; i++) {
      r -= weights[i];
      if (r <= 0 && weights[i] > 0) {
        pick = pool[i];
        break;
      }
    }
    _current = pick;
    _hint = false;
    _scramble = Scrambler.forCase(pick.scrambles, pick.scrambleFrom, pick.algs.indexOf(state.mainAlg(pick)));
  }

  void _onSolved(int ms, Penalty p) {
    final c = _current;
    if (c == null) return;
    AppScope.read(context).addTime(c.id, ms);
    _seen[c.id] = _round;
    _round++;
    setState(() {
      _lastCase = c;
      _lastMs = ms;
      _reveal = false;
      _next();
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (!widget.active || e.logicalKey != LogicalKeyboardKey.space || _current == null) {
      return KeyEventResult.ignored;
    }
    if (e is KeyDownEvent) _timer!.down();
    if (e is KeyUpEvent) _timer!.up();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context);
    final th = Theme.of(context);
    final timer = _timer!;
    final focusMode = timer.phase == TimerPhase.running || timer.phase == TimerPhase.ready;
    final pool = _pool(state);

    final Color timeColor = switch (timer.phase) {
      TimerPhase.holding => AppTheme.statusLearning,
      TimerPhase.ready => AppTheme.statusLearned,
      _ => th.colorScheme.onSurface,
    };
    final timeText = switch (timer.phase) {
      TimerPhase.running => Stats.format(timer.elapsedMs),
      TimerPhase.holding || TimerPhase.ready => Stats.format(0),
      _ => _lastMs == null ? Stats.format(0) : Stats.format(_lastMs),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(t.tr('trainer')),
        automaticallyImplyLeading: widget.standalone,
        actions: [
          IconButton(
            tooltip: t.tr('slowest_cases'),
            onPressed: () => _showSlowest(context, pool),
            icon: const Icon(Icons.trending_down_rounded),
          ),
          IconButton(
            tooltip: t.tr('trainer_setup'),
            onPressed: () => _showSetup(context),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: Focus(
        focusNode: _focus,
        autofocus: widget.active,
        onKeyEvent: _onKey,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: focusMode ? 0 : 1,
                child: Column(children: [
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        for (final s in kAlgSets.where((s) => _sets.contains(s.id)))
                          Padding(
                            padding: const EdgeInsets.only(right: 6, top: 4, bottom: 4),
                            child: CountPill(color: AppTheme.colorForSet(s.id), text: s.title),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: CountPill(
                            color: th.colorScheme.onSurfaceVariant,
                            icon: Icons.layers_rounded,
                            text: '${pool.length} ${t.tr('cases')}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
                        child: _current == null
                            ? Row(children: [
                                Expanded(child: Text(t.tr('trainer_empty'))),
                                TextButton(onPressed: () => _showSetup(context), child: Text(t.tr('trainer_setup'))),
                              ])
                            : Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(t.tr('scramble').toUpperCase(),
                                            style: th.textTheme.labelSmall?.copyWith(
                                                letterSpacing: 1.2, color: th.colorScheme.onSurfaceVariant)),
                                        const SizedBox(height: 6),
                                        Text(_scramble, style: AppTheme.mono.copyWith(fontSize: 19, height: 1.35)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => setState(() => _hint = !_hint),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      child: _hint
                                          ? CasePreview(
                                              key: ValueKey(_current!.id),
                                              algCase: _current!,
                                              size: 72,
                                              grayscale: state.grayscale,
                                            )
                                          : Container(
                                              key: const ValueKey('hidden'),
                                              width: 72,
                                              height: 72,
                                              decoration: BoxDecoration(
                                                color: th.colorScheme.surfaceContainerHighest,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Icon(Icons.visibility_rounded,
                                                  color: th.colorScheme.onSurfaceVariant),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ]),
              ),
              Expanded(
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) {
                    if (_current != null) timer.down();
                  },
                  onPointerUp: (_) {
                    if (_current != null) timer.up();
                  },
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 120),
                          style: TextStyle(
                            fontSize: 76,
                            fontWeight: FontWeight.w800,
                            color: timeColor,
                            letterSpacing: -2,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                          child: Text(timeText),
                        ),
                        const SizedBox(height: 6),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: timer.phase == TimerPhase.running ? 0 : 1,
                          child: Text(
                            t.tr(timer.phase == TimerPhase.ready ? 'release_to_start' : 'hold_to_start'),
                            style: th.textTheme.bodyMedium?.copyWith(color: th.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: focusMode ? 0 : 1,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _lastCase == null
                      ? const SizedBox(height: 8)
                      : _LastResult(
                          key: ValueKey('$_round'),
                          algCase: _lastCase!,
                          ms: _lastMs ?? 0,
                          reveal: _reveal,
                          onReveal: () => setState(() => _reveal = !_reveal),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSlowest(BuildContext context, List<AlgCase> pool) {
    final state = AppScope.read(context);
    final t = AppLocalizations.of(context);
    final timed = pool.where((c) => state.avgTime(c.id) != null).toList()
      ..sort((a, b) => state.avgTime(b.id)!.compareTo(state.avgTime(a.id)!));
    final top = timed.take(5).toList();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.tr('slowest_cases'), style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(t.tr('slowest_desc'), style: Theme.of(ctx).textTheme.bodySmall),
              const SizedBox(height: 8),
              if (top.isEmpty)
                Padding(padding: const EdgeInsets.all(16), child: Text(t.tr('no_times_yet')))
              else
                for (final c in top)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CasePreview(algCase: c, size: 48, grayscale: state.grayscale),
                    title: Text(c.title),
                    subtitle: Text(state.mainAlg(c), maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.mono),
                    trailing: Text(Stats.format(state.avgTime(c.id)!.round()),
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => CaseScreen(algCase: c)));
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSetup(BuildContext context) async {
    final t = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          void upd(VoidCallback f) {
            setS(f);
            setState(() {});
          }

          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            maxChildSize: 0.95,
            builder: (ctx, scroll) => ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                Text(t.tr('trainer_setup'), style: Theme.of(ctx).textTheme.titleLarge),
                for (final m in Method.values) ...[
                  const SizedBox(height: 16),
                  Text(methodName(t, m), style: Theme.of(ctx).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final s in AlgRepo.byMethod(m))
                      FilterChip(
                        label: Text('${s.title} · ${s.cases.length}'),
                        selected: _sets.contains(s.id),
                        selectedColor: AppTheme.colorForSet(s.id).withValues(alpha: 0.25),
                        onSelected: (v) => upd(() => v ? _sets.add(s.id) : _sets.remove(s.id)),
                      ),
                  ]),
                ],
                const SizedBox(height: 20),
                Text(t.tr('status'), style: Theme.of(ctx).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final s in LearnStatus.values)
                    FilterChip(
                      avatar: Icon(statusIcon(s), size: 16, color: statusColor(s)),
                      label: Text(statusLabel(t, s)),
                      selected: _statuses.contains(s),
                      onSelected: (v) => upd(() {
                        final n = {..._statuses};
                        v ? n.add(s) : n.remove(s);
                        if (n.isNotEmpty) _statuses = n;
                      }),
                    ),
                ]),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.tr('favorites_only')),
                  value: _favOnly,
                  onChanged: (v) => upd(() => _favOnly = v),
                ),
              ],
            ),
          );
        },
      ),
    );
    if (mounted) setState(_next);
  }
}

class _LastResult extends StatelessWidget {
  final AlgCase algCase;
  final int ms;
  final bool reveal;
  final VoidCallback onReveal;
  const _LastResult({super.key, required this.algCase, required this.ms, required this.reveal, required this.onReveal});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context);
    final th = Theme.of(context);
    final c = algCase;
    final times = state.times(c.id);
    final best = times.isEmpty ? null : times.reduce(math.min);
    final color = AppTheme.colorForSet(AlgRepo.setOfCase[c.id]!.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TintCard(
        color: color,
        padding: const EdgeInsets.all(12),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CaseScreen(algCase: c))),
        child: Row(
          children: [
            CasePreview(algCase: c, size: 64, grayscale: state.grayscale),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text('${t.tr('last_case')}: ${c.title}',
                          maxLines: 1, overflow: TextOverflow.ellipsis, style: th.textTheme.titleSmall),
                    ),
                    Text(Stats.format(ms), style: th.textTheme.titleMedium?.copyWith(color: color)),
                  ]),
                  const SizedBox(height: 2),
                  Text(
                    '${t.tr('best')} ${Stats.format(best)} · ${t.tr('average')} ${Stats.format(state.avgTime(c.id)?.round())}',
                    style: th.textTheme.labelSmall?.copyWith(color: th.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onReveal,
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      crossFadeState: reveal ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      firstChild: Text(t.tr('show_alg'),
                          style: th.textTheme.labelLarge?.copyWith(color: th.colorScheme.primary)),
                      secondChild: Text(state.mainAlg(c), style: AppTheme.mono.copyWith(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
