import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../logic/scramble.dart';
import '../logic/speed_timer.dart';
import '../logic/stats.dart';
import '../models/rubiks_cube.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/cube_3d.dart';
import 'session_screen.dart';

/// Full solve timer with sessions, WCA inspection and ao5/ao12/ao100.
class TimerScreen extends StatefulWidget {
  final bool active;
  const TimerScreen({super.key, this.active = true});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final _focus = FocusNode(debugLabel: 'timer');
  SpeedTimer? _timer;
  String _scramble = '';
  RubiksCube _preview = RubiksCube();
  String _sessionId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppScope.of(context);
    if (_timer == null) {
      _timer = SpeedTimer(holdMs: state.holdMs, useInspection: state.inspection, onSolved: _onSolved)
        ..addListener(_onTick);
    } else if (!_timer!.busy) {
      _timer!
        ..holdMs = state.holdMs
        ..useInspection = state.inspection;
    }
    if (_sessionId != state.currentSessionId) {
      _sessionId = state.currentSessionId;
      _newScramble(state);
    }
  }

  @override
  void didUpdateWidget(covariant TimerScreen old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _focus.requestFocus();
    } else if (!widget.active && old.active) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.removeListener(_onTick);
    _timer?.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _newScramble(AppState state) {
    _scramble = state.currentSession.puzzle == '222' ? Scrambler.cube2() : Scrambler.cube3();
    _preview = RubiksCube()..applyScramble(_scramble);
  }

  void _onSolved(int ms, Penalty p) {
    final state = AppScope.read(context);
    state.addSolve(Solve(ms: ms, scramble: _scramble, at: DateTime.now().millisecondsSinceEpoch, penalty: p));
    setState(() => _newScramble(state));
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (!widget.active || e.logicalKey != LogicalKeyboardKey.space) return KeyEventResult.ignored;
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
    final session = state.currentSession;
    final solves = session.solves;
    final last = solves.isEmpty ? null : solves.last;
    final focusMode = timer.busy;
    final is2 = session.puzzle == '222';

    // --- big display ---
    String display;
    Color color = th.colorScheme.onSurface;
    if (timer.phase == TimerPhase.running) {
      display = Stats.format(timer.elapsedMs);
    } else if (timer.inInspection) {
      final ms = timer.inspectionMs;
      display = ms < 15000 ? '${15 - ms ~/ 1000}' : '+2';
      color = ms < 8000 ? th.colorScheme.primary : (ms < 12000 ? AppTheme.statusLearning : AppTheme.statusNew);
      if (timer.phase == TimerPhase.holding) color = AppTheme.statusNew;
      if (timer.phase == TimerPhase.ready) color = AppTheme.statusLearned;
    } else if (timer.phase == TimerPhase.holding) {
      display = Stats.format(0);
      color = AppTheme.statusNew;
    } else if (timer.phase == TimerPhase.ready) {
      display = Stats.format(0);
      color = AppTheme.statusLearned;
    } else {
      display = last == null ? Stats.format(0) : Stats.formatSolve(last);
    }

    final hint = switch (timer.phase) {
      TimerPhase.running => t.tr('tap_to_stop'),
      TimerPhase.ready => t.tr('release_to_start'),
      TimerPhase.inspecting => t.tr('inspection_hint'),
      _ => t.tr(state.inspection ? 'tap_for_inspection' : 'hold_to_start'),
    };

    return Scaffold(
      body: Focus(
        focusNode: _focus,
        autofocus: widget.active,
        onKeyEvent: _onKey,
        child: SafeArea(
          child: Column(
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: focusMode ? 0 : 1,
                child: IgnorePointer(
                  ignoring: focusMode,
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                      child: Row(children: [
                        Expanded(child: _SessionMenu(onChanged: () => setState(() => _newScramble(state)))),
                        IconButton(
                          tooltip: t.tr('statistics'),
                          onPressed: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => const SessionScreen())),
                          icon: const Icon(Icons.insights_rounded),
                        ),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                          child: Row(children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${t.tr('scramble').toUpperCase()} · ${is2 ? '2×2' : '3×3'}',
                                    style: th.textTheme.labelSmall
                                        ?.copyWith(letterSpacing: 1.2, color: th.colorScheme.onSurfaceVariant),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(_scramble, style: AppTheme.mono.copyWith(fontSize: 16.5, height: 1.4)),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      tooltip: t.tr('new_scramble'),
                                      onPressed: () => setState(() => _newScramble(state)),
                                      icon: const Icon(Icons.refresh_rounded, size: 20),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      tooltip: t.tr('copy'),
                                      onPressed: () => Clipboard.setData(ClipboardData(text: _scramble)),
                                      icon: const Icon(Icons.copy_rounded, size: 18),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                            CubeView(cube: _preview, size: 96, twoByTwo: is2, interactive: false, shadow: false),
                          ]),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              Expanded(
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) => timer.down(),
                  onPointerUp: (_) => timer.up(),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 120),
                            style: TextStyle(
                              fontSize: 92,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -3,
                              color: color,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                            child: Text(display),
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: timer.phase == TimerPhase.running ? 0.5 : 1,
                          child: Text(hint,
                              style: th.textTheme.bodyMedium?.copyWith(color: th.colorScheme.onSurfaceVariant)),
                        ),
                        if (last != null && !focusMode && timer.phase != TimerPhase.inspecting) ...[
                          const SizedBox(height: 14),
                          _PenaltyBar(solve: last),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: focusMode ? 0 : 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _StatsRow(solves: solves),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PenaltyBar extends StatelessWidget {
  final Solve solve;
  const _PenaltyBar({required this.solve});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context);
    Widget chip(String label, Penalty p) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(label),
            selected: solve.penalty == p,
            onSelected: (_) => state.setPenalty(solve, solve.penalty == p ? Penalty.none : p),
          ),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        chip('+2', Penalty.plus2),
        chip('DNF', Penalty.dnf),
        IconButton(
          tooltip: t.tr('delete'),
          onPressed: () => state.deleteSolve(solve),
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<Solve> solves;
  const _StatsRow({required this.solves});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final items = <(String, String)>[
      (t.tr('best'), Stats.format(Stats.best(solves))),
      ('ao5', Stats.formatAvg(Stats.averageOf(solves, 5))),
      ('ao12', Stats.formatAvg(Stats.averageOf(solves, 12))),
      ('ao100', Stats.formatAvg(Stats.averageOf(solves, 100))),
      (t.tr('mean'), Stats.format(Stats.mean(solves))),
      (t.tr('solves'), '${solves.length}'),
    ];
    final th = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            for (final (label, value) in items)
              Expanded(
                child: Column(children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(value,
                        style: th.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800, fontFeatures: const [FontFeature.tabularFigures()])),
                  ),
                  const SizedBox(height: 2),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: th.textTheme.labelSmall?.copyWith(color: th.colorScheme.onSurfaceVariant)),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}

class _SessionMenu extends StatelessWidget {
  final VoidCallback onChanged;
  const _SessionMenu({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context);
    final th = Theme.of(context);
    final s = state.currentSession;
    return Align(
      alignment: Alignment.centerLeft,
      child: PopupMenuButton<String>(
        tooltip: t.tr('sessions'),
        onSelected: (v) async {
          if (v.startsWith('s:')) {
            state.selectSession(v.substring(2));
            onChanged();
          } else if (v == 'new') {
            final r = await _sessionDialog(context, t.tr('new_session'), '', '333', askPuzzle: true);
            if (r != null) {
              state.createSession(r.$1, r.$2);
              onChanged();
            }
          } else if (v == 'rename' && context.mounted) {
            final r = await _sessionDialog(context, t.tr('rename'), s.name, s.puzzle, askPuzzle: false);
            if (r != null) state.renameSession(s.id, r.$1);
          } else if (v == 'delete' && context.mounted) {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(t.tr('delete_session')),
                content: Text(t.tr('delete_session_q').replaceAll('{name}', s.name)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.tr('cancel'))),
                  FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.tr('delete'))),
                ],
              ),
            );
            if (ok == true) {
              state.deleteSession(s.id);
              onChanged();
            }
          }
        },
        itemBuilder: (ctx) => [
          for (final x in state.sessions)
            PopupMenuItem(
              value: 's:${x.id}',
              child: Row(children: [
                Icon(x.id == s.id ? Icons.check_rounded : Icons.circle_outlined, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(x.name, overflow: TextOverflow.ellipsis)),
                Text(x.puzzle == '222' ? '2×2' : '3×3', style: Theme.of(ctx).textTheme.labelSmall),
              ]),
            ),
          const PopupMenuDivider(),
          PopupMenuItem(value: 'new', child: _MenuRow(Icons.add_rounded, t.tr('new_session'))),
          PopupMenuItem(value: 'rename', child: _MenuRow(Icons.edit_rounded, t.tr('rename'))),
          PopupMenuItem(value: 'delete', child: _MenuRow(Icons.delete_outline_rounded, t.tr('delete_session'))),
        ],
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
          decoration: BoxDecoration(
            color: th.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.folder_rounded, size: 18, color: th.colorScheme.primary),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(s.name, overflow: TextOverflow.ellipsis, style: th.textTheme.titleSmall),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more_rounded, size: 20),
          ]),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MenuRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) =>
      Row(children: [Icon(icon, size: 18), const SizedBox(width: 10), Text(text)]);
}

Future<(String, String)?> _sessionDialog(BuildContext context, String title, String name, String puzzle,
    {required bool askPuzzle}) {
  final t = AppLocalizations.of(context);
  final ctl = TextEditingController(text: name);
  var pz = puzzle;
  return showDialog<(String, String)>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setD) => AlertDialog(
        title: Text(title),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: ctl,
            autofocus: true,
            decoration: InputDecoration(hintText: t.tr('session_name')),
          ),
          if (askPuzzle) ...[
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '333', label: Text('3×3')),
                ButtonSegment(value: '222', label: Text('2×2')),
              ],
              selected: {pz},
              onSelectionChanged: (v) => setD(() => pz = v.first),
            ),
          ],
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.tr('cancel'))),
          FilledButton(
            onPressed: () {
              final n = ctl.text.trim();
              Navigator.pop(ctx, (n.isEmpty ? (pz == '222' ? '2x2' : '3x3') : n, pz));
            },
            child: Text(t.tr('save')),
          ),
        ],
      ),
    ),
  );
}
