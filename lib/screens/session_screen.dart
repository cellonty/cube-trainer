import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../logic/stats.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Statistics of the current timer session: graph + solve list.
class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = AppLocalizations.of(context);
    final th = Theme.of(context);
    final session = state.currentSession;
    final solves = session.solves;
    final ao5 = Stats.rollingAo5(solves);

    final stats = <(String, String)>[
      (t.tr('best'), Stats.format(Stats.best(solves))),
      (t.tr('mean'), Stats.format(Stats.mean(solves))),
      ('ao5', Stats.formatAvg(Stats.averageOf(solves, 5))),
      ('ao12', Stats.formatAvg(Stats.averageOf(solves, 12))),
      ('ao50', Stats.formatAvg(Stats.averageOf(solves, 50))),
      ('ao100', Stats.formatAvg(Stats.averageOf(solves, 100))),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(session.name)),
      body: solves.isEmpty
          ? Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.timer_outlined, size: 56, color: th.colorScheme.onSurfaceVariant),
                const SizedBox(height: 8),
                Text(t.tr('no_solves')),
              ]),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          _Legend(color: th.colorScheme.primary, text: t.tr('solves')),
                          const SizedBox(width: 14),
                          _Legend(color: AppTheme.statusLearning, text: 'ao5'),
                        ]),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 200,
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _GraphPainter(
                              solves: solves,
                              ao5: ao5,
                              line: th.colorScheme.primary,
                              avgLine: AppTheme.statusLearning,
                              grid: th.colorScheme.outlineVariant.withValues(alpha: 0.35),
                              label: th.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.6,
                  children: [
                    for (final (label, value) in stats)
                      Card(
                        margin: EdgeInsets.zero,
                        child: Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text(value,
                                style: th.textTheme.titleMedium
                                    ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                            const SizedBox(height: 2),
                            Text(label,
                                style: th.textTheme.labelSmall?.copyWith(color: th.colorScheme.onSurfaceVariant)),
                          ]),
                        ),
                      ),
                  ],
                ),
                SectionHeader(
                  title: '${t.tr('solves')} (${solves.length})',
                  padding: const EdgeInsets.fromLTRB(4, 22, 4, 8),
                ),
                Card(
                  child: Column(
                    children: [
                      for (var i = solves.length - 1; i >= 0; i--)
                        ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: th.colorScheme.primary.withValues(alpha: 0.14),
                            child: Text('${i + 1}',
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w800, color: th.colorScheme.primary)),
                          ),
                          title: Text(Stats.formatSolve(solves[i]),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontFeatures: [FontFeature.tabularFigures()])),
                          subtitle: Text(solves[i].scramble,
                              maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.mono.copyWith(fontSize: 12)),
                          trailing: ao5[i] == null
                              ? null
                              : Text('ao5 ${Stats.format(ao5[i])}', style: th.textTheme.labelSmall),
                          onTap: () => _showSolve(context, solves[i], i + 1),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showSolve(BuildContext context, Solve s, int n) {
    final state = AppScope.read(context);
    final t = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final dt = DateTime.fromMillisecondsSinceEpoch(s.at);
        final when = '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#$n · ${Stats.formatSolve(s)}', style: Theme.of(ctx).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(when, style: Theme.of(ctx).textTheme.bodySmall),
                const SizedBox(height: 12),
                SelectableText(s.scramble, style: AppTheme.mono.copyWith(fontSize: 15)),
                const SizedBox(height: 16),
                SegmentedButton<Penalty>(
                  segments: const [
                    ButtonSegment(value: Penalty.none, label: Text('OK')),
                    ButtonSegment(value: Penalty.plus2, label: Text('+2')),
                    ButtonSegment(value: Penalty.dnf, label: Text('DNF')),
                  ],
                  selected: {s.penalty},
                  onSelectionChanged: (v) {
                    state.setPenalty(s, v.first);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 12),
                Row(children: [
                  TextButton.icon(
                    onPressed: () => Clipboard.setData(ClipboardData(text: s.scramble)),
                    icon: const Icon(Icons.copy_rounded),
                    label: Text(t.tr('copy')),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: AppTheme.statusNew),
                    onPressed: () {
                      state.deleteSolve(s);
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(t.tr('delete')),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;
  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 14, height: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.labelSmall),
      ]);
}

class _GraphPainter extends CustomPainter {
  final List<Solve> solves;
  final List<int?> ao5;
  final Color line, avgLine, grid, label;

  _GraphPainter({
    required this.solves,
    required this.ao5,
    required this.line,
    required this.avgLine,
    required this.grid,
    required this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const maxPoints = 100;
    final start = math.max(0, solves.length - maxPoints);
    final pts = <(int, int)>[];
    final avg = <(int, int)>[];
    for (var i = start; i < solves.length; i++) {
      final e = solves[i].effective;
      if (e != null) pts.add((i - start, e));
      final a = ao5[i];
      if (a != null) avg.add((i - start, a));
    }
    if (pts.isEmpty) return;
    final all = [...pts.map((p) => p.$2), ...avg.map((p) => p.$2)];
    var lo = all.reduce(math.min).toDouble();
    var hi = all.reduce(math.max).toDouble();
    if (hi - lo < 1000) {
      hi += 500;
      lo = math.max(0, lo - 500);
    }
    final padY = (hi - lo) * 0.1;
    lo = math.max(0, lo - padY);
    hi += padY;

    const left = 44.0;
    final w = size.width - left;
    final h = size.height;
    final n = math.max(1, solves.length - start - 1);
    Offset pos(int x, int y) => Offset(left + w * x / n, h - h * (y - lo) / (hi - lo));

    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var k = 0; k <= 3; k++) {
      final v = lo + (hi - lo) * k / 3;
      final y = h - h * k / 3;
      canvas.drawLine(Offset(left, y), Offset(size.width, y), gridPaint);
      final tp = TextPainter(
        text: TextSpan(text: Stats.format(v.round()), style: TextStyle(fontSize: 10, color: label)),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: left - 4);
      tp.paint(canvas, Offset(0, (y - tp.height / 2).clamp(0, h - tp.height)));
    }

    void drawSeries(List<(int, int)> s, Color c, double width, {bool fill = false, bool dots = false}) {
      if (s.isEmpty) return;
      final path = Path()..moveTo(pos(s.first.$1, s.first.$2).dx, pos(s.first.$1, s.first.$2).dy);
      for (final p in s.skip(1)) {
        final o = pos(p.$1, p.$2);
        path.lineTo(o.dx, o.dy);
      }
      if (fill && s.length > 1) {
        final area = Path.from(path)
          ..lineTo(pos(s.last.$1, s.last.$2).dx, h)
          ..lineTo(pos(s.first.$1, s.first.$2).dx, h)
          ..close();
        canvas.drawPath(
          area,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [c.withValues(alpha: 0.25), c.withValues(alpha: 0.0)],
            ).createShader(Offset.zero & size),
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = c
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
      if (dots && s.length <= 50) {
        final dp = Paint()..color = c;
        for (final p in s) {
          canvas.drawCircle(pos(p.$1, p.$2), 2.6, dp);
        }
      }
    }

    drawSeries(pts, line, 1.6, fill: true, dots: true);
    drawSeries(avg, avgLine, 2.6);
  }

  @override
  bool shouldRepaint(covariant _GraphPainter old) => true;
}
