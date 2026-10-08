import 'package:flutter/material.dart';
import '../models/rubiks_cube.dart';

class CubePreview3D extends StatelessWidget {
  final RubiksCube cube;
  final double size;

  const CubePreview3D({Key? key, required this.cube, this.size = 110})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _IsoPainter(cube),
    );
  }
}

class _IsoPainter extends CustomPainter {
  final RubiksCube cube;
  _IsoPainter(this.cube);

  static const _colorMap = {
    'W': Color(0xFFFFFFFF),
    'Y': Color(0xFFFFD500),
    'O': Color(0xFFFF8B00),
    'R': Color(0xFFD50000),
    'G': Color(0xFF00B84A),
    'B': Color(0xFF0051BA),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final double e = s * 0.44;
    final double cell = e / 3.0;

    const double cos30 = 0.8660254;
    const double sin30 = 0.5;

    final Offset vR = Offset(cos30 * cell, sin30 * cell);
    final Offset vL = Offset(-cos30 * cell, sin30 * cell);
    final Offset vD = Offset(0, cell);

    final double cx = s / 2;
    final double topY = (s - 2 * e) / 2;
    final Offset top = Offset(cx, topY);
    final Offset bottom = top + vR * 3 + vL * 3;
    final Offset left = top + vL * 3;

    final border = Paint()
      ..color = const Color(0xFF101010)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..isAntiAlias = true;

    _drawFace(canvas, cube.f['F']!, left, vR, vD, border);
    _drawFace(canvas, cube.f['R']!, bottom, -vL, vD, border);
    _drawFace(canvas, cube.f['U']!, top, vR, vL, border);
  }

  void _drawFace(
    Canvas canvas,
    List<String> face,
    Offset origin,
    Offset colDir,
    Offset rowDir,
    Paint border,
  ) {
    final fill = Paint()..isAntiAlias = true;

    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 3; c++) {
        final idx = r * 3 + c;
        final color = _colorMap[face[idx]] ?? Colors.grey;

        final p00 = origin + colDir * c.toDouble() + rowDir * r.toDouble();
        final p10 = origin + colDir * (c + 1).toDouble() + rowDir * r.toDouble();
        final p11 = origin +
            colDir * (c + 1).toDouble() +
            rowDir * (r + 1).toDouble();
        final p01 =
            origin + colDir * c.toDouble() + rowDir * (r + 1).toDouble();

        final path = Path()
          ..moveTo(p00.dx, p00.dy)
          ..lineTo(p10.dx, p10.dy)
          ..lineTo(p11.dx, p11.dy)
          ..lineTo(p01.dx, p01.dy)
          ..close();

        canvas.drawPath(path, fill..color = color);
        canvas.drawPath(path, border);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IsoPainter old) => true;
}