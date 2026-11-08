import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../logic/alg_tools.dart';
import '../models/alg_models.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'cube_3d.dart';
import 'll_view.dart';

class ProgressRing extends StatelessWidget {
  final double value;
  final double size;
  final double stroke;
  final Color color;
  final Color? track;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 56,
    this.stroke = 6,
    this.track,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (_, v, c) => CustomPaint(
          painter: _RingPainter(v, color, track ?? color.withValues(alpha: 0.18), stroke),
          child: Center(child: c),
        ),
        child: child,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double v;
  final Color color, track;
  final double stroke;
  _RingPainter(this.v, this.color, this.track, this.stroke);

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, 0, math.pi * 2, false, p..color = track);
    if (v > 0) canvas.drawArc(r, -math.pi / 2, math.pi * 2 * v, false, p..color = color);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.v != v || o.color != color || o.track != track;
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsets padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 10),
  });

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: th.textTheme.titleLarge),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!,
                        style: th.textTheme.bodySmall?.copyWith(color: th.colorScheme.onSurfaceVariant)),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

Color statusColor(LearnStatus s) => switch (s) {
      LearnStatus.notLearned => AppTheme.statusNew,
      LearnStatus.learning => AppTheme.statusLearning,
      LearnStatus.learned => AppTheme.statusLearned,
    };

String statusLabel(AppLocalizations t, LearnStatus s) => switch (s) {
      LearnStatus.notLearned => t.tr('status_new'),
      LearnStatus.learning => t.tr('status_learning'),
      LearnStatus.learned => t.tr('status_learned'),
    };

IconData statusIcon(LearnStatus s) => switch (s) {
      LearnStatus.notLearned => Icons.radio_button_unchecked_rounded,
      LearnStatus.learning => Icons.timelapse_rounded,
      LearnStatus.learned => Icons.check_circle_rounded,
    };

class StatusPill extends StatelessWidget {
  final LearnStatus status;
  final bool compact;
  const StatusPill({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final c = statusColor(status);
    final t = AppLocalizations.of(context);
    if (compact) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle, boxShadow: [
          BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 6),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(statusIcon(status), size: 14, color: c),
        const SizedBox(width: 4),
        Text(statusLabel(t, status), style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 12)),
      ]),
    );
  }
}

/// Counter pill like "12 learned".
class CountPill extends StatelessWidget {
  final Color color;
  final String text;
  final IconData? icon;
  const CountPill({super.key, required this.color, required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
        ],
        Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12.5)),
      ]),
    );
  }
}

/// Preview of a case: top-down diagram for last-layer sets, 3D cube otherwise.
class CasePreview extends StatelessWidget {
  final AlgCase algCase;
  final double size;
  final bool grayscale;
  final bool? forceTop;

  const CasePreview({
    super.key,
    required this.algCase,
    this.size = 100,
    required this.grayscale,
    this.forceTop,
  });

  @override
  Widget build(BuildContext context) {
    final cube = AlgRepo.caseCube(algCase);
    final goal = algCase.goal;
    final mask = grayscale ? StickerMask.forGoal(cube, goal) : null;
    final top = forceTop ?? _useTop(goal);
    if (top) {
      return LastLayerView(
        cube: cube,
        size: size,
        twoByTwo: goal.isTwoByTwo,
        mask: mask,
        arrows: goal == CaseGoal.pll || goal == CaseGoal.ell,
      );
    }
    return CubeView(
      cube: cube,
      size: size,
      twoByTwo: goal.isTwoByTwo,
      mask: mask,
      interactive: false,
      shadow: false,
    );
  }

  static bool _useTop(CaseGoal g) => switch (g) {
        CaseGoal.oll || CaseGoal.eo || CaseGoal.ocll || CaseGoal.pll || CaseGoal.coll || CaseGoal.ell => true,
        CaseGoal.cmll || CaseGoal.cll => true,
        _ => false,
      };
}

/// Rounded card with a soft coloured gradient.
class TintCard extends StatelessWidget {
  final Color color;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  const TintCard({
    super.key,
    required this.color,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return Card(
      child: Ink(
        decoration: BoxDecoration(gradient: AppTheme.tile(color, b)),
        child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
      ),
    );
  }
}

String methodName(AppLocalizations t, Method m) => switch (m) {
      Method.cfop => 'CFOP',
      Method.roux => 'Roux',
      Method.cube2 => t.tr('method_2x2'),
    };
