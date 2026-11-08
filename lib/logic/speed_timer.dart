import 'dart:async';

import 'package:flutter/foundation.dart';

import 'stats.dart';

enum TimerPhase { idle, inspecting, holding, ready, running, stopped }

/// Stackmat-like timer: hold, release to start, press to stop.
/// Optional WCA inspection (15 s, +2 after 15 s, DNF after 17 s).
class SpeedTimer extends ChangeNotifier {
  SpeedTimer({required this.holdMs, required this.useInspection, required this.onSolved});

  int holdMs;
  bool useInspection;
  final void Function(int ms, Penalty penalty) onSolved;

  TimerPhase phase = TimerPhase.idle;
  int lastMs = 0;
  Penalty lastPenalty = Penalty.none;

  final Stopwatch _solve = Stopwatch();
  final Stopwatch _insp = Stopwatch();
  final Stopwatch _hold = Stopwatch();
  Timer? _tick;
  bool _holdFromInspection = false;
  bool _ignoreUp = false;
  bool _pendingInspection = false;
  Penalty _startPenalty = Penalty.none;

  int get elapsedMs => phase == TimerPhase.running ? _solve.elapsedMilliseconds : 0;
  int get inspectionMs => _insp.elapsedMilliseconds;
  bool get inInspection => _insp.isRunning;
  bool get busy =>
      phase == TimerPhase.running ||
      phase == TimerPhase.ready ||
      phase == TimerPhase.inspecting ||
      (phase == TimerPhase.holding && _holdFromInspection);

  void _ensureTick() {
    _tick ??= Timer.periodic(const Duration(milliseconds: 16), (_) => _onTick());
  }

  void _stopTick() {
    _tick?.cancel();
    _tick = null;
  }

  void _onTick() {
    if (phase == TimerPhase.holding && _hold.elapsedMilliseconds >= holdMs) {
      phase = TimerPhase.ready;
    }
    if (_insp.isRunning && _insp.elapsedMilliseconds >= 17000 && phase != TimerPhase.running) {
      // did not start within 17 s -> DNF
      _insp
        ..stop()
        ..reset();
      _hold
        ..stop()
        ..reset();
      phase = TimerPhase.stopped;
      lastMs = 0;
      lastPenalty = Penalty.dnf;
      _ignoreUp = true;
      _stopTick();
      onSolved(0, Penalty.dnf);
    }
    notifyListeners();
  }

  void down() {
    switch (phase) {
      case TimerPhase.running:
        _solve.stop();
        lastMs = _solve.elapsedMilliseconds;
        lastPenalty = _startPenalty;
        phase = TimerPhase.stopped;
        _ignoreUp = true;
        _stopTick();
        notifyListeners();
        onSolved(lastMs, lastPenalty);
      case TimerPhase.idle:
      case TimerPhase.stopped:
        if (useInspection) {
          _pendingInspection = true;
        } else {
          _startHold(false);
        }
      case TimerPhase.inspecting:
        _startHold(true);
      case TimerPhase.holding:
      case TimerPhase.ready:
        break;
    }
  }

  void up() {
    if (_ignoreUp) {
      _ignoreUp = false;
      return;
    }
    switch (phase) {
      case TimerPhase.ready:
        _startSolve();
      case TimerPhase.holding:
        _hold
          ..stop()
          ..reset();
        phase = _holdFromInspection ? TimerPhase.inspecting : (lastMs > 0 ? TimerPhase.stopped : TimerPhase.idle);
        if (!_holdFromInspection) _stopTick();
        notifyListeners();
      case TimerPhase.idle:
      case TimerPhase.stopped:
        if (_pendingInspection) {
          _pendingInspection = false;
          _insp
            ..reset()
            ..start();
          phase = TimerPhase.inspecting;
          _ensureTick();
          notifyListeners();
        }
      case TimerPhase.inspecting:
      case TimerPhase.running:
        break;
    }
  }

  void _startHold(bool fromInspection) {
    _holdFromInspection = fromInspection;
    _hold
      ..reset()
      ..start();
    phase = TimerPhase.holding;
    _ensureTick();
    notifyListeners();
  }

  void _startSolve() {
    _startPenalty = Penalty.none;
    if (_insp.isRunning) {
      final ms = _insp.elapsedMilliseconds;
      if (ms > 17000) {
        _startPenalty = Penalty.dnf;
      } else if (ms > 15000) {
        _startPenalty = Penalty.plus2;
      }
      _insp
        ..stop()
        ..reset();
    }
    _hold
      ..stop()
      ..reset();
    _solve
      ..reset()
      ..start();
    phase = TimerPhase.running;
    _ensureTick();
    notifyListeners();
  }

  /// Cancels inspection/holding (e.g. when the screen is left).
  void cancel() {
    _insp
      ..stop()
      ..reset();
    _hold
      ..stop()
      ..reset();
    if (phase != TimerPhase.running) {
      phase = lastMs > 0 ? TimerPhase.stopped : TimerPhase.idle;
      _stopTick();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopTick();
    super.dispose();
  }
}
