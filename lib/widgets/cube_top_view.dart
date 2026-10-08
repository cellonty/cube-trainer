import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/rubiks_cube.dart';

class CubeTopView extends StatelessWidget {
  final RubiksCube cube;
  final double size;
  final List<List<int>>? arrows;

  const CubeTopView({
    Key? key,
    required this.cube,
    this.size = 110,
    this.arrows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TopPainter(cube, arrows),
      ),
    );
  }
}

class _TopPainter extends CustomPainter {
  final RubiksCube cube;
  final List<List<int>>? arrows;

  _TopPainter(this.cube, this.arrows);

  static const _colorMap = {
    'W': Color(0xFFFFFFFF),
    'Y': Color(0xFFFFD500),
    'O': Color(0xFFFF8B00),
    'R': Color(0xFFD50000),
    'G': Color(0xFF00B84A),
    'B': Color(0xFF0051BA),
  };

  static const _gray = Color(0xFFB5B5B5);

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);

    final dx = (size.width - s) / 2;
    final dy = (size.height - s) / 2;

    final strip = s * 0.11;
    final face = s * 0.78;
    final cell = face / 3;

    final left = dx;
    final top = dy;
    final right = left + s;
    final bottom = top + s;

    final faceLeft = left + strip;
    final faceTop = top + strip;
    final faceRight = faceLeft + face;
    final faceBottom = faceTop + face;

    final thin = Paint()
      ..color = const Color(0xFF101010)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final thick = Paint()
      ..color = const Color(0xFF0A0A0A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..isAntiAlias = true;

    _drawStrip(
      canvas,
      cube.f['B']!,
      Rect.fromLTRB(faceLeft, top, faceRight, faceTop),
      horizontal: true,
      reverse: true,
      border: thin,
    );

    _drawStrip(
      canvas,
      cube.f['F']!,
      Rect.fromLTRB(faceLeft, faceBottom, faceRight, bottom),
      horizontal: true,
      reverse: false,
      border: thin,
    );

    _drawStrip(
      canvas,
      cube.f['L']!,
      Rect.fromLTRB(left, faceTop, faceLeft, faceBottom),
      horizontal: false,
      reverse: false,
      border: thin,
    );

    _drawStrip(
      canvas,
      cube.f['R']!,
      Rect.fromLTRB(faceRight, faceTop, right, faceBottom),
      horizontal: false,
      reverse: true,
      border: thin,
    );

    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        final idx = r * 3 + c;
        final color = _colorMap[cube.f['U']![idx]] ?? _gray;
        final rect = Rect.fromLTWH(
          faceLeft + c * cell,
          faceTop + r * cell,
          cell,
          cell,
        );
        canvas.drawRect(rect, Paint()..color = color);
        canvas.drawRect(rect, thin);
      }
    }

    canvas.drawRect(
      Rect.fromLTRB(faceLeft, faceTop, faceRight, faceBottom),
      thick,
    );

    if (arrows != null) {
      for (final a in arrows!) {
        _drawArrow(canvas, a[0], a[1], faceLeft, faceTop, cell);
      }
    }
  }

  void _drawStrip(
    Canvas canvas,
    List<String> face,
    Rect rect, {
    required bool horizontal,
    required bool reverse,
    required Paint border,
  }) {
    for (var i = 0; i < 3; i++) {
      final color = _colorMap[face[i]] ?? _gray;
      final pos = reverse ? (2 - i) : i;

      final cellRect = horizontal
          ? Rect.fromLTWH(
              rect.left + pos * (rect.width / 3),
              rect.top,
              rect.width / 3,
              rect.height,
            )
          : Rect.fromLTWH(
              rect.left,
              rect.top + pos * (rect.height / 3),
              rect.width,
              rect.height / 3,
            );

      canvas.drawRect(cellRect, Paint()..color = color);
      canvas.drawRect(cellRect, border);
    }
  }

  Offset _cellCenter(int idx, double faceLeft, double faceTop, double cell) {
    final r = idx ~/ 3;
    final c = idx % 3;
    return Offset(faceLeft + (c + 0.5) * cell, faceTop + (r + 0.5) * cell);
  }

  void _drawArrow(
    Canvas canvas,
    int fromCell,
    int toCell,
    double faceLeft,
    double faceTop,
    double cell,
  ) {
    final from = _cellCenter(fromCell, faceLeft, faceTop, cell);
    final to = _cellCenter(toCell, faceLeft, faceTop, cell);

    final dir = to - from;
    final len = dir.distance;
    if (len < 1) return;

    final unit = dir / len;
    final start = from + unit * (cell * 0.18);
    final end = to - unit * (cell * 0.42);

    final linePaint = Paint()
      ..color = const Color(0xFF0D47A1)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawLine(start, end, linePaint);

    final aPerp = Offset(-unit.dy, unit.dx);
    final headSize = cell * 0.40;
    final headWidth = headSize * 0.55;

    final tip = end + unit * (cell * 0.06);
    final left = tip - unit * headSize + aPerp * headWidth;
    final right = tip - unit * headSize - aPerp * headWidth;

    final headPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();

    canvas.drawPath(headPath, Paint()..color = const Color(0xFF0D47A1));
  }

  @override
  bool shouldRepaint(covariant _TopPainter old) => true;
}