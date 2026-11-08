import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../logic/alg_tools.dart';
import '../models/rubiks_cube.dart';
import '../theme/app_theme.dart';

/// Classic top-down diagram: U face plus the top row of every side.
class LastLayerView extends StatelessWidget {
  final RubiksCube cube;
  final double size;
  final bool twoByTwo;
  final Set<String>? mask;
  final bool arrows;

  const LastLayerView({
    super.key,
    required this.cube,
    this.size = 120,
    this.twoByTwo = false,
    this.mask,
    this.arrows = false,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.square(size),
        painter: _LLPainter(
          cube: cube,
          twoByTwo: twoByTwo,
          mask: mask,
          arrows: arrows,
          frame: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}

class _LLPainter extends CustomPainter {
  final RubiksCube cube;
  final bool twoByTwo;
  final Set<String>? mask;
  final bool arrows;
  final Color frame;

  _LLPainter({
    required this.cube,
    required this.twoByTwo,
    required this.mask,
    required this.arrows,
    required this.frame,
  });

  static const _cornerSlots = {8: 'UFR', 6: 'UFL', 0: 'UBL', 2: 'UBR'};
  static const _edgeSlots = {7: 'UF', 5: 'UR', 1: 'UB', 3: 'UL'};
  static const _cornerCycle = [8, 6, 0, 2]; // U turn moves 8->6->0->2
  static const _edgeCycle = [7, 3, 1, 5];

  Color _color(String face, int i) {
    final key = '$face,$i';
    if (mask != null && !mask!.contains(key)) return AppTheme.maskedSticker;
    return AppTheme.sticker[cube.f[face]![i]] ?? Colors.grey;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = twoByTwo ? 2 : 3;
    final s = size.shortestSide;
    final cell = s / (n + 1.05);
    final strip = cell * 0.34;
    final gap = cell * 0.075;
    final ox = (size.width - n * cell) / 2;
    final oy = (size.height - n * cell) / 2;
    final idx = twoByTwo ? const [0, 2] : const [0, 1, 2];

    // background plate
    final plate = RRect.fromRectAndRadius(
      Rect.fromLTWH(ox - strip - gap * 2, oy - strip - gap * 2, n * cell + 2 * (strip + gap * 2),
          n * cell + 2 * (strip + gap * 2)),
      Radius.circular(cell * 0.32),
    );
    canvas.drawRRect(plate, Paint()..color = AppTheme.cubeBody);

    void sticker(Rect r, Color c) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r.deflate(gap / 2), Radius.circular(cell * 0.14)),
        Paint()..color = c,
      );
    }

    int uIndex(int col, int row) => twoByTwo ? (row * 6 + col * 2) : row * 3 + col;

    for (var row = 0; row < n; row++) {
      for (var col = 0; col < n; col++) {
        sticker(Rect.fromLTWH(ox + col * cell, oy + row * cell, cell, cell), _color('U', uIndex(col, row)));
      }
    }
    for (var j = 0; j < n; j++) {
      final a = idx[j];
      final b = idx[n - 1 - j];
      // back (top of the diagram), left to right: B2 B1 B0
      sticker(Rect.fromLTWH(ox + j * cell, oy - strip - gap, cell, strip), _color('B', b));
      // front (bottom), left to right: F0 F1 F2
      sticker(Rect.fromLTWH(ox + j * cell, oy + n * cell + gap, cell, strip), _color('F', a));
      // left, top to bottom: L0 L1 L2
      sticker(Rect.fromLTWH(ox - strip - gap, oy + j * cell, strip, cell), _color('L', a));
      // right, top to bottom: R2 R1 R0
      sticker(Rect.fromLTWH(ox + n * cell + gap, oy + j * cell, strip, cell), _color('R', b));
    }

    if (arrows) _drawArrows(canvas, ox, oy, cell);
  }

  Offset _center(int u, double ox, double oy, double cell) {
    final col = twoByTwo ? (u % 3 == 0 ? 0 : 1) : u % 3;
    final row = twoByTwo ? (u < 3 ? 0 : 1) : u ~/ 3;
    return Offset(ox + (col + 0.5) * cell, oy + (row + 0.5) * cell);
  }

  Map<int, int> _targets(Map<int, String> slots, List<int> cycle, int k) {
    // home slot of the piece currently at each slot, shifted by k AUF steps
    final out = <int, int>{};
    final homeByColors = <String, int>{};
    final solved = RubiksCube();
    for (final e in slots.entries) {
      final piece = _pieceStickers(e.value);
      homeByColors[_colorsKey(solved, piece)] = e.key;
    }
    for (final e in slots.entries) {
      final piece = _pieceStickers(e.value);
      final home = homeByColors[_colorsKey(cube, piece)];
      if (home == null) return {};
      final i = cycle.indexOf(home);
      out[e.key] = cycle[(i + k) % 4];
    }
    return out;
  }

  static List<String> _pieceStickers(String name) =>
      CubeChecks.corners[name] ?? CubeChecks.edges[name]!;

  static String _colorsKey(RubiksCube c, List<String> piece) =>
      (piece.map((s) => CubeChecks.at(c, s)).toList()..sort()).join();

  void _drawArrows(Canvas canvas, double ox, double oy, double cell) {
    var best = <int, int>{};
    var bestMoved = 1 << 30;
    for (var k = 0; k < 4; k++) {
      final t = <int, int>{
        ..._targets(_cornerSlots, _cornerCycle, k),
        if (!twoByTwo) ..._targets(_edgeSlots, _edgeCycle, k),
      };
      if (t.isEmpty) return;
      final moved = t.entries.where((e) => e.key != e.value).length;
      if (moved < bestMoved) {
        bestMoved = moved;
        best = t;
      }
    }
    final done = <int>{};
    final stroke = Paint()
      ..color = const Color(0xFF111111)
      ..strokeWidth = cell * 0.075
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final halo = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = cell * 0.15
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final e in best.entries) {
      final from = e.key, to = e.value;
      if (from == to || done.contains(from)) continue;
      final swap = best[to] == from;
      if (swap) done.addAll([from, to]);
      final a = _center(from, ox, oy, cell);
      final b = _center(to, ox, oy, cell);
      final d = b - a;
      final len = d.distance;
      if (len == 0) continue;
      final u = d / len;
      final p1 = a + u * cell * 0.22;
      final p2 = b - u * cell * 0.22;
      for (final p in [halo, stroke]) {
        canvas.drawLine(p1, p2, p);
        _head(canvas, p2, u, cell, p);
        if (swap) _head(canvas, p1, -u, cell, p);
      }
    }
  }

  void _head(Canvas canvas, Offset tip, Offset dir, double cell, Paint p) {
    final ang = math.atan2(dir.dy, dir.dx);
    final h = cell * 0.2;
    final l = tip - Offset(math.cos(ang - 0.5), math.sin(ang - 0.5)) * h;
    final r = tip - Offset(math.cos(ang + 0.5), math.sin(ang + 0.5)) * h;
    canvas.drawPath(Path()
      ..moveTo(l.dx, l.dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(r.dx, r.dy), p);
  }

  @override
  bool shouldRepaint(_LLPainter old) => true;
}
