import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../logic/alg_tools.dart';
import '../models/rubiks_cube.dart';
import '../theme/app_theme.dart';

class _V {
  final double x, y, z;
  const _V(this.x, this.y, this.z);
  _V operator +(_V o) => _V(x + o.x, y + o.y, z + o.z);
  _V operator -(_V o) => _V(x - o.x, y - o.y, z - o.z);
  _V operator *(double s) => _V(x * s, y * s, z * s);
  double comp(int a) => a == 0 ? x : (a == 1 ? y : z);
}

/// Right-handed rotation of [p] around axis (0=x, 1=y, 2=z) by angle [a].
_V _rot(_V p, int axis, double a) {
  if (a == 0) return p;
  final c = math.cos(a), s = math.sin(a);
  switch (axis) {
    case 0:
      return _V(p.x, p.y * c - p.z * s, p.y * s + p.z * c);
    case 1:
      return _V(p.z * s + p.x * c, p.y, p.z * c - p.x * s);
    default:
      return _V(p.x * c - p.y * s, p.x * s + p.y * c, p.z);
  }
}

class _M3 {
  final int axis;
  final List<int> layers;
  final int q; // quarter turns (counter-clockwise about +axis) for one clockwise move
  const _M3(this.axis, this.layers, this.q);
}

const Map<String, _M3> _moves3d = {
  'R': _M3(0, [1], -1),
  'L': _M3(0, [-1], 1),
  'M': _M3(0, [0], 1),
  'U': _M3(1, [1], -1),
  'D': _M3(1, [-1], 1),
  'E': _M3(1, [0], 1),
  'F': _M3(2, [1], -1),
  'B': _M3(2, [-1], 1),
  'S': _M3(2, [0], -1),
  'r': _M3(0, [0, 1], -1),
  'l': _M3(0, [-1, 0], 1),
  'u': _M3(1, [0, 1], -1),
  'd': _M3(1, [-1, 0], 1),
  'f': _M3(2, [0, 1], -1),
  'b': _M3(2, [-1, 0], 1),
  'x': _M3(0, [-1, 0, 1], -1),
  'y': _M3(1, [-1, 0, 1], -1),
  'z': _M3(2, [-1, 0, 1], -1),
};

class _Facelet {
  final String face;
  final int idx;
  final _V cubie; // integer cubie position (-1..1)
  final _V n, u, v;
  const _Facelet(this.face, this.idx, this.cubie, this.n, this.u, this.v);
}

final List<_Facelet> _facelets = () {
  final out = <_Facelet>[];
  for (final face in const ['U', 'D', 'F', 'B', 'R', 'L']) {
    for (var i = 0; i < 9; i++) {
      final r = (i ~/ 3).toDouble(), c = (i % 3).toDouble();
      final (cubie, n, u, v) = switch (face) {
        'U' => (_V(c - 1, 1, r - 1), const _V(0, 1, 0), const _V(1, 0, 0), const _V(0, 0, 1)),
        'D' => (_V(c - 1, -1, 1 - r), const _V(0, -1, 0), const _V(1, 0, 0), const _V(0, 0, -1)),
        'F' => (_V(c - 1, 1 - r, 1), const _V(0, 0, 1), const _V(1, 0, 0), const _V(0, -1, 0)),
        'B' => (_V(1 - c, 1 - r, -1), const _V(0, 0, -1), const _V(-1, 0, 0), const _V(0, -1, 0)),
        'R' => (_V(1, 1 - r, 1 - c), const _V(1, 0, 0), const _V(0, 0, -1), const _V(0, -1, 0)),
        _ => (_V(-1, 1 - r, c - 1), const _V(-1, 0, 0), const _V(0, 0, 1), const _V(0, -1, 0)),
      };
      out.add(_Facelet(face, i, cubie, n, u, v));
    }
  }
  return out;
}();

class _Run {
  final int lo, hi;
  final bool moving;
  _Run(this.lo, this.hi, this.moving);
}

/// Paints a 3D cube (3x3 or 2x2), optionally in the middle of a layer turn.
class CubePainter extends CustomPainter {
  final RubiksCube cube;
  final String? move;
  final double t;
  final double yaw, pitch;
  final bool twoByTwo;
  final Set<String>? mask;
  final bool shadow;

  CubePainter({
    required this.cube,
    this.move,
    this.t = 0,
    this.yaw = -0.62,
    this.pitch = 0.5,
    this.twoByTwo = false,
    this.mask,
    this.shadow = true,
  });

  static const double _persp = 9;

  @override
  void paint(Canvas canvas, Size size) {
    final k = twoByTwo ? 0.5 : 1.0;
    final radius = twoByTwo ? 1.75 : 2.62;
    final scale = size.shortestSide / 2 / (radius * 1.08);
    final cx = size.width / 2, cy = size.height / 2 - (shadow ? size.height * 0.03 : 0);

    _V view(_V p) => _rot(_rot(p, 1, yaw), 0, pitch);
    Offset proj(_V q) {
      final f = _persp / (_persp - q.z);
      return Offset(cx + q.x * scale * f, cy - q.y * scale * f);
    }

    if (shadow) {
      final r = Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.9),
        width: size.shortestSide * 0.62,
        height: size.shortestSide * 0.1,
      );
      canvas.drawOval(
        r,
        Paint()
          ..shader = RadialGradient(colors: [
            Colors.black.withValues(alpha: 0.32),
            Colors.black.withValues(alpha: 0),
          ]).createShader(r),
      );
    }

    // ---- which layers move ----
    _M3? m;
    double angle = 0;
    if (move != null) {
      final (base, times) = AlgTools.split(move!);
      m = _moves3d[base];
      if (m != null) angle = m.q * (times == 3 ? -1 : times) * math.pi / 2 * t;
    }
    final runs = <_Run>[];
    if (m == null) {
      runs.add(_Run(-1, 1, false));
    } else {
      for (final l in const [-1, 0, 1]) {
        final mv = m.layers.contains(l);
        if (runs.isNotEmpty && runs.last.moving == mv) {
          runs[runs.length - 1] = _Run(runs.last.lo, l, mv);
        } else {
          runs.add(_Run(l, l, mv));
        }
      }
    }
    final axis = m?.axis ?? 0;

    double boundary(int a, int b) => twoByTwo ? 0 : (a + b) / 2;

    final body = Paint()..color = AppTheme.cubeBody;
    final runOrder = [...runs];
    _V runCenter(_Run r) {
      final c = (r.lo + r.hi) / 2 * k;
      final p = axis == 0 ? _V(c, 0, 0) : (axis == 1 ? _V(0, c, 0) : _V(0, 0, c));
      return view(r.moving ? _rot(p, axis, angle) : p);
    }

    runOrder.sort((a, b) => runCenter(a).z.compareTo(runCenter(b).z));

    for (final run in runOrder) {
      final a = run.moving ? angle : 0.0;
      _V tr(_V p) => view(_rot(p, axis, a));

      // caps (inner faces of the moving block)
      if (m != null) {
        final ext = twoByTwo ? 1.0 : 1.5;
        final caps = <(double, double)>[];
        if (run.lo > -1) caps.add((boundary(run.lo - 1, run.lo), -1));
        if (run.hi < 1) caps.add((boundary(run.hi, run.hi + 1), 1));
        for (final (pos, dir) in caps) {
          final nrm = axis == 0 ? _V(dir, 0, 0) : (axis == 1 ? _V(0, dir, 0) : _V(0, 0, dir));
          final vn = tr(nrm);
          if (vn.z <= 0.01) continue;
          final o1 = axis == 0 ? 1 : 0;
          final o2 = axis == 2 ? 1 : 2;
          _V mk(double p1, double p2) {
            final c = [0.0, 0.0, 0.0];
            c[axis] = pos;
            c[o1] = p1;
            c[o2] = p2;
            return _V(c[0], c[1], c[2]);
          }

          final pts = [mk(-ext, -ext), mk(ext, -ext), mk(ext, ext), mk(-ext, ext)]
              .map((p) => proj(tr(p)))
              .toList();
          canvas.drawPath(Path()..addPolygon(pts, true), body);
        }
      }

      for (final fl in _facelets) {
        if (twoByTwo && !const {0, 2, 6, 8}.contains(fl.idx)) continue;
        final layer = fl.cubie.comp(axis).round();
        if (m != null && (layer < run.lo || layer > run.hi)) continue;
        final vn = tr(fl.n);
        if (vn.z <= 0.01) continue;
        final center = fl.cubie * k + fl.n * 0.5;
        List<Offset> quad(double h) => [
              proj(tr(center - fl.u * h - fl.v * h)),
              proj(tr(center + fl.u * h - fl.v * h)),
              proj(tr(center + fl.u * h + fl.v * h)),
              proj(tr(center - fl.u * h + fl.v * h)),
            ];
        canvas.drawPath(Path()..addPolygon(quad(0.515), true), body);
        final key = '${fl.face},${fl.idx}';
        final letter = cube.f[fl.face]![fl.idx];
        final base = (mask == null || mask!.contains(key))
            ? (AppTheme.sticker[letter] ?? Colors.grey)
            : AppTheme.maskedSticker;
        final shade = 0.7 + 0.3 * vn.z.clamp(0.0, 1.0);
        final col = Color.lerp(Colors.black, base, shade)!;
        final stickerPath = _rounded(quad(0.43), 0.2);
        canvas.drawPath(stickerPath, Paint()..color = col);
        // soft highlight
        canvas.drawPath(
          stickerPath,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8
            ..color = Colors.white.withValues(alpha: 0.10 * shade),
        );
      }
    }
  }

  static Path _rounded(List<Offset> p, double k) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final prev = p[(i + 3) % 4], cur = p[i], next = p[(i + 1) % 4];
      final a = Offset.lerp(cur, prev, k)!, b = Offset.lerp(cur, next, k)!;
      if (i == 0) {
        path.moveTo(a.dx, a.dy);
      } else {
        path.lineTo(a.dx, a.dy);
      }
      path.quadraticBezierTo(cur.dx, cur.dy, b.dx, b.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(CubePainter old) => true;
}

/// 3D cube that can be rotated by dragging.
class CubeView extends StatefulWidget {
  final RubiksCube cube;
  final double size;
  final bool twoByTwo;
  final Set<String>? mask;
  final String? move;
  final double t;
  final bool interactive;
  final bool shadow;
  final double initialYaw;
  final double initialPitch;

  const CubeView({
    super.key,
    required this.cube,
    this.size = 200,
    this.twoByTwo = false,
    this.mask,
    this.move,
    this.t = 0,
    this.interactive = true,
    this.shadow = true,
    this.initialYaw = -0.62,
    this.initialPitch = 0.5,
  });

  @override
  State<CubeView> createState() => _CubeViewState();
}

class _CubeViewState extends State<CubeView> {
  late double _yaw = widget.initialYaw;
  late double _pitch = widget.initialPitch;

  @override
  Widget build(BuildContext context) {
    final paint = CustomPaint(
      size: Size.square(widget.size),
      painter: CubePainter(
        cube: widget.cube,
        move: widget.move,
        t: widget.t,
        yaw: widget.interactive ? _yaw : widget.initialYaw,
        pitch: widget.interactive ? _pitch : widget.initialPitch,
        twoByTwo: widget.twoByTwo,
        mask: widget.mask,
        shadow: widget.shadow,
      ),
    );
    if (!widget.interactive) return RepaintBoundary(child: paint);
    return GestureDetector(
      onPanUpdate: (d) => setState(() {
        _yaw += d.delta.dx * 0.012;
        _pitch = (_pitch + d.delta.dy * 0.012).clamp(-1.45, 1.45);
      }),
      onDoubleTap: () => setState(() {
        _yaw = widget.initialYaw;
        _pitch = widget.initialPitch;
      }),
      child: paint,
    );
  }
}

/// Slowly spinning decorative cube (home screen hero).
class SpinningCube extends StatefulWidget {
  final double size;
  const SpinningCube({super.key, this.size = 120});

  @override
  State<SpinningCube> createState() => _SpinningCubeState();
}

class _SpinningCubeState extends State<SpinningCube> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  final RubiksCube _cube = RubiksCube()..applyScramble("R U R' U' F2 D L2 B");

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => CustomPaint(
        size: Size.square(widget.size),
        painter: CubePainter(
          cube: _cube,
          yaw: -0.62 + _c.value * 2 * math.pi,
          pitch: 0.5 + 0.12 * math.sin(_c.value * 2 * math.pi),
          shadow: false,
        ),
      ),
    );
  }
}
