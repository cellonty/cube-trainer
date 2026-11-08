import 'dart:convert';

enum Penalty { none, plus2, dnf }

class Solve {
  final int ms;
  Penalty penalty;
  final String scramble;
  final int at;

  Solve({required this.ms, required this.scramble, required this.at, this.penalty = Penalty.none});

  /// Time with penalty applied, null for DNF.
  int? get effective => penalty == Penalty.dnf
      ? null
      : penalty == Penalty.plus2
          ? ms + 2000
          : ms;

  Map<String, dynamic> toJson() => {'ms': ms, 'p': penalty.index, 's': scramble, 't': at};

  factory Solve.fromJson(Map<String, dynamic> j) => Solve(
        ms: (j['ms'] as num).toInt(),
        scramble: (j['s'] as String?) ?? '',
        at: (j['t'] as num?)?.toInt() ?? 0,
        penalty: Penalty.values[((j['p'] as num?)?.toInt() ?? 0).clamp(0, 2)],
      );
}

class Session {
  final String id;
  String name;
  final String puzzle; // '333' or '222'
  final List<Solve> solves;

  Session({required this.id, required this.name, required this.puzzle, List<Solve>? solves})
      : solves = solves ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'puzzle': puzzle,
        'solves': solves.map((s) => s.toJson()).toList(),
      };

  factory Session.fromJson(Map<String, dynamic> j) => Session(
        id: j['id'] as String,
        name: (j['name'] as String?) ?? 'Session',
        puzzle: (j['puzzle'] as String?) ?? '333',
        solves: ((j['solves'] as List?) ?? [])
            .map((e) => Solve.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  static String encodeAll(List<Session> list) => jsonEncode(list.map((s) => s.toJson()).toList());

  static List<Session> decodeAll(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final l = jsonDecode(raw) as List;
      return l.map((e) => Session.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }
}

/// Result of an average: [value] in ms, or [dnf] = true.
class AvgResult {
  final int? value;
  final bool dnf;
  const AvgResult(this.value, this.dnf);
}

class Stats {
  /// WCA-style trimmed average of the last [n] solves.
  /// Returns null if there are not enough solves.
  static AvgResult? averageOf(List<Solve> solves, int n) {
    if (solves.length < n) return null;
    final last = solves.sublist(solves.length - n);
    final trim = n >= 100 ? 5 : (n >= 5 ? 1 : 0);
    final dnfs = last.where((s) => s.effective == null).length;
    if (dnfs > trim) return const AvgResult(null, true);
    final times = last.map((s) => s.effective ?? 1 << 40).toList()..sort();
    final kept = times.sublist(trim, times.length - trim);
    final sum = kept.fold<int>(0, (a, b) => a + b);
    return AvgResult((sum / kept.length).round(), false);
  }

  static int? best(List<Solve> solves) {
    int? b;
    for (final s in solves) {
      final e = s.effective;
      if (e != null && (b == null || e < b)) b = e;
    }
    return b;
  }

  static int? mean(List<Solve> solves) {
    final v = solves.map((s) => s.effective).whereType<int>().toList();
    if (v.isEmpty) return null;
    return (v.reduce((a, b) => a + b) / v.length).round();
  }

  /// Rolling ao5 for the graph (null where not available / DNF).
  static List<int?> rollingAo5(List<Solve> solves) {
    final out = <int?>[];
    for (var i = 0; i < solves.length; i++) {
      if (i < 4) {
        out.add(null);
        continue;
      }
      final r = averageOf(solves.sublist(0, i + 1), 5);
      out.add(r == null || r.dnf ? null : r.value);
    }
    return out;
  }

  static String format(int? ms, {bool dnf = false}) {
    if (dnf) return 'DNF';
    if (ms == null) return '—';
    final totalCs = (ms / 10).floor();
    final cs = totalCs % 100;
    final s = (totalCs ~/ 100) % 60;
    final m = totalCs ~/ 6000;
    final css = cs.toString().padLeft(2, '0');
    if (m > 0) return '$m:${s.toString().padLeft(2, '0')}.$css';
    return '$s.$css';
  }

  static String formatAvg(AvgResult? r) {
    if (r == null) return '—';
    return format(r.value, dnf: r.dnf);
  }

  static String formatSolve(Solve s) {
    if (s.penalty == Penalty.dnf) return 'DNF(${format(s.ms)})';
    if (s.penalty == Penalty.plus2) return '${format(s.ms + 2000)}+';
    return format(s.ms);
  }
}
