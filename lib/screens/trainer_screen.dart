import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/alg_database.dart';
import '../services/favorite_service.dart';
import '../services/trainer_service.dart';
import '../models/rubiks_cube.dart';
import '../widgets/cube_preview_3d.dart';
import '../widgets/cube_top_view.dart';
import '../l10n/app_localizations.dart';

class TrainerScreen extends StatefulWidget {
  const TrainerScreen({Key? key}) : super(key: key);

  @override
  State<TrainerScreen> createState() => _TrainerScreenState();
}

class _TrainerScreenState extends State<TrainerScreen> {
  final _favService = FavoriteService();
  final _trainerService = TrainerService();
  final _rand = Random();

  List<dynamic> _all = [];
  List<dynamic> _pool = [];
  dynamic _current;
  List<int> _times = [];

  bool _loading = true;
  bool _useFavorites = true;
  bool _showAlg = false;

  Timer? _timer;
  DateTime? _startTime;
  int _elapsedMs = 0;
  bool _running = false;

  RubiksCube? _cube;
  List<List<int>>? _arrows;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    _all = [
      ...AlgDatabase.f2l,
      ...AlgDatabase.oll,
      ...AlgDatabase.pll,
      ...AlgDatabase.rouxCMLL,
      ...AlgDatabase.rouxLSE,
    ];
    await _rebuildPool();
    setState(() => _loading = false);
  }

  Future<void> _rebuildPool() async {
    final favs = await _favService.loadAll();
    if (_useFavorites && favs.isNotEmpty) {
      _pool = _all.where((a) => favs.contains(a.name as String)).toList();
    } else {
      _pool = List.from(_all);
    }
    _pool.shuffle(_rand);
    await _pickNext();
  }

  Future<void> _pickNext() async {
    _stop();
    if (_pool.isEmpty) {
      setState(() {
        _current = null;
        _cube = null;
        _arrows = null;
        _times = [];
        _elapsedMs = 0;
      });
      return;
    }
    final next = _pool.removeLast();
    final times = await _trainerService.getTimes(next.name as String);

    final c = RubiksCube();
    c.applyScramble(next.scramble as String);

    setState(() {
      _current = next;
      _times = times;
      _elapsedMs = 0;
      _showAlg = false;
      _cube = c;
      _arrows = (next.name as String).startsWith('PLL')
          ? c.computePllArrows()
          : null;
    });
  }

  void _start() {
    _startTime = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (_startTime == null) return;
      setState(() {
        _elapsedMs = DateTime.now().difference(_startTime!).inMilliseconds;
      });
    });
    setState(() => _running = true);
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    setState(() => _running = false);
  }

  Future<void> _save() async {
    if (_current == null || _elapsedMs <= 0) return;
    await _trainerService.addTime(_current.name as String, _elapsedMs);
    final times = await _trainerService.getTimes(_current.name as String);
    setState(() => _times = times);
  }

  String _fmt(int ms) {
    if (ms == 0) return '0.00';
    if (ms < 60000) return (ms / 1000).toStringAsFixed(2);
    final m = ms ~/ 60000;
    final s = ((ms % 60000) / 1000).toStringAsFixed(2).padLeft(5, '0');
    return '$m:$s';
  }

  int? get _best => _times.isEmpty ? null : _times.reduce(min);

  int? get _avg5 {
    if (_times.isEmpty) return null;
    final n = min(5, _times.length);
    final last = _times.sublist(_times.length - n);
    return last.reduce((a, b) => a + b) ~/ n;
  }

  int? get _avg12 {
    if (_times.isEmpty) return null;
    final n = min(12, _times.length);
    final last = _times.sublist(_times.length - n);
    return last.reduce((a, b) => a + b) ~/ n;
  }

  Widget _buildPreview() {
    if (_cube == null || _current == null) return const SizedBox.shrink();
    if ((_current.name as String).startsWith('F2L')) {
      return CubePreview3D(cube: _cube!, size: 130);
    }
    return CubeTopView(cube: _cube!, size: 130, arrows: _arrows);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.trainer),
        actions: [
          IconButton(
            icon: Icon(_useFavorites ? Icons.favorite : Icons.favorite_border),
            tooltip: _useFavorites ? t.trainerFavs : t.trainerAll,
            onPressed: () async {
              setState(() => _useFavorites = !_useFavorites);
              await _rebuildPool();
            },
          ),
        ],
      ),
      body: _current == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  t.trainerNoFavs,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _current.name as String,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildPreview(),
                        const SizedBox(height: 12),
                        Text(
                          t.trainerScramble,
                          style: theme.textTheme.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          _current.scramble as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _fmt(_elapsedMs),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: _running
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: _running
                        ? ElevatedButton.icon(
                            onPressed: _stop,
                            icon: const Icon(Icons.stop_rounded, size: 40),
                            label: Text(
                              t.trainerStop,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: _start,
                            icon: const Icon(Icons.play_arrow_rounded, size: 40),
                            label: Text(
                              t.trainerStart,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                  ),
                  if (!_running && _elapsedMs > 0) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await _save();
                                await _pickNext();
                              },
                              icon: const Icon(Icons.check),
                              label: Text(
                                t.trainerNext,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 54,
                          child: OutlinedButton(
                            onPressed: () => setState(() => _elapsedMs = 0),
                            child: Text(
                              t.trainerReset,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  _statsRow(theme, t),
                  const SizedBox(height: 16),
                  if (_times.isNotEmpty) _recentTimes(theme, t),
                  const SizedBox(height: 16),
                  _algBox(theme, t),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _statsRow(ThemeData theme, AppLocalizations t) {
    Widget item(String label, String? value) {
      return Expanded(
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value ?? '—',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          item(t.trainerBest, _best != null ? _fmt(_best!) : null),
          item(t.trainerAvg5, _avg5 != null ? _fmt(_avg5!) : null),
          item(t.trainerAvg12, _avg12 != null ? _fmt(_avg12!) : null),
        ],
      ),
    );
  }

  Widget _recentTimes(ThemeData theme, AppLocalizations t) {
    final last = _times.length > 10
        ? _times.sublist(_times.length - 10)
        : _times;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.trainerRecent,
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: last.map((ms) {
            final isBest = _best != null && ms == _best;
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isBest
                    ? theme.colorScheme.primary.withOpacity(0.2)
                    : theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _fmt(ms),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: isBest ? FontWeight.bold : FontWeight.normal,
                  color: isBest ? theme.colorScheme.primary : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _algBox(ThemeData theme, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton.icon(
          onPressed: () => setState(() => _showAlg = !_showAlg),
          icon: Icon(
            _showAlg ? Icons.visibility_off : Icons.visibility,
            size: 18,
          ),
          label: Text(_showAlg ? t.trainerHideAlg : t.trainerShowAlg),
        ),
        if (_showAlg) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SelectableText(
              _current.alg as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              await _trainerService.clearTimes(_current.name as String);
              setState(() => _times = []);
            },
            icon: const Icon(Icons.delete_outline, size: 16),
            label: Text(t.trainerClear),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ],
    );
  }
}