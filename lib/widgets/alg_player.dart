import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../logic/alg_tools.dart';
import '../models/alg_models.dart';
import '../models/rubiks_cube.dart';
import '../theme/app_theme.dart';
import 'cube_3d.dart';

/// Animated 3D playback of an algorithm: play / pause / step / speed.
class AlgPlayer extends StatefulWidget {
  final String setup;
  final String alg;
  final bool twoByTwo;
  final CaseGoal? goal;
  final bool grayscale;
  final double size;

  const AlgPlayer({
    super.key,
    required this.setup,
    required this.alg,
    this.twoByTwo = false,
    this.goal,
    this.grayscale = false,
    this.size = 260,
  });

  @override
  State<AlgPlayer> createState() => _AlgPlayerState();
}

class _AlgPlayerState extends State<AlgPlayer> with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late RubiksCube _start;
  late RubiksCube _cube;
  List<String> _tokens = const [];
  int _step = 0;
  String? _anim;
  int _dir = 1;
  bool _playing = false;
  double _speed = 1;

  static const _speeds = [0.5, 1.0, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380))
      ..addListener(() => setState(() {}))
      ..addStatusListener(_onStatus);
    _reset();
  }

  @override
  void didUpdateWidget(AlgPlayer old) {
    super.didUpdateWidget(old);
    if (old.setup != widget.setup || old.alg != widget.alg) {
      _ctl.stop();
      _reset();
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  void _reset() {
    _start = RubiksCube()..applyScramble(widget.setup);
    _cube = _start.clone();
    _tokens = AlgTools.tokens(widget.alg);
    _step = 0;
    _anim = null;
    _playing = false;
    _ctl.value = 0;
  }

  void _onStatus(AnimationStatus s) {
    if (s != AnimationStatus.completed || _anim == null) return;
    setState(() {
      _cube.applyMove(_anim!);
      _step += _dir;
      _anim = null;
      _ctl.value = 0;
    });
    if (_playing) {
      if (_step < _tokens.length) {
        Future.microtask(_forward);
      } else {
        setState(() => _playing = false);
      }
    }
  }

  void _run(String token, int dir) {
    final (_, times) = AlgTools.split(token);
    _anim = token;
    _dir = dir;
    _ctl.duration = Duration(milliseconds: ((times == 2 ? 540 : 380) / _speed).round());
    _ctl.forward(from: 0);
  }

  void _forward() {
    if (!mounted || _anim != null || _step >= _tokens.length) return;
    _run(_tokens[_step], 1);
  }

  void _back() {
    if (_anim != null || _step == 0) return;
    _run(AlgTools.invertToken(_tokens[_step - 1]), -1);
  }

  void _togglePlay() {
    setState(() {
      if (_playing) {
        _playing = false;
        return;
      }
      if (_step >= _tokens.length) {
        _cube = _start.clone();
        _step = 0;
      }
      _playing = true;
    });
    if (_playing) _forward();
  }

  void _restart() {
    _ctl.stop();
    setState(_reset);
  }

  void _toEnd() {
    _ctl.stop();
    setState(() {
      _anim = null;
      _playing = false;
      _cube = _start.clone()..applyScramble(_tokens.join(' '));
      _step = _tokens.length;
      _ctl.value = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final mask = widget.grayscale && widget.goal != null ? StickerMask.forGoal(_cube, widget.goal!) : null;
    final progress = _tokens.isEmpty ? 0.0 : (_step + (_anim == null ? 0 : _dir * _ctl.value)) / _tokens.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: RadialGradient(
              center: const Alignment(0, -0.2),
              radius: 0.9,
              colors: [
                scheme.primary.withValues(alpha: 0.16),
                scheme.primary.withValues(alpha: 0.0),
              ],
            ),
          ),
          child: Center(
            child: CubeView(
              cube: _cube,
              size: widget.size,
              twoByTwo: widget.twoByTwo,
              mask: mask,
              move: _anim,
              t: Curves.easeInOut.transform(_ctl.value),
            ),
          ),
        ),
        Text(t.tr('drag_to_rotate'), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: progress.clamp(0.0, 1.0), minHeight: 6),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          runSpacing: 4,
          children: [
            for (var i = 0; i < _tokens.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: i == _step && _step < _tokens.length
                      ? scheme.primary
                      : (i < _step ? scheme.primary.withValues(alpha: 0.14) : scheme.surfaceContainer),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _tokens[i],
                  style: AppTheme.mono.copyWith(
                    fontSize: 15,
                    color: i == _step && _step < _tokens.length
                        ? scheme.onPrimary
                        : (i < _step ? scheme.primary : scheme.onSurface),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(tooltip: t.tr('restart'), onPressed: _restart, icon: const Icon(Icons.replay_rounded)),
            IconButton.filledTonal(
              tooltip: t.tr('step_back'),
              onPressed: _step > 0 && _anim == null ? _back : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 64,
              height: 64,
              child: IconButton.filled(
                tooltip: _playing ? t.tr('pause') : t.tr('play'),
                onPressed: _togglePlay,
                iconSize: 34,
                icon: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
              ),
            ),
            const SizedBox(width: 6),
            IconButton.filledTonal(
              tooltip: t.tr('step_forward'),
              onPressed: _step < _tokens.length && _anim == null ? _forward : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
            IconButton(tooltip: t.tr('to_end'), onPressed: _toEnd, icon: const Icon(Icons.skip_next_rounded)),
          ],
        ),
        TextButton.icon(
          onPressed: () => setState(() {
            final i = _speeds.indexOf(_speed);
            _speed = _speeds[(i + 1) % _speeds.length];
          }),
          icon: const Icon(Icons.speed_rounded, size: 18),
          label: Text('${t.tr('speed')}: ${_speed.toString().replaceAll('.0', '')}×'),
        ),
      ],
    );
  }
}
