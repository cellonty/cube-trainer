import 'dart:math';

/// Random-move scrambles (WCA-style notation).
class Scrambler {
  static final Random _rnd = Random();
  static const _suffixes = ['', "'", '2'];
  static const _axis = {'U': 0, 'D': 0, 'F': 1, 'B': 1, 'R': 2, 'L': 2};

  static String cube3([int length = 20]) =>
      _generate(const ['U', 'D', 'F', 'B', 'R', 'L'], length);

  static String cube2() => _generate(const ['R', 'U', 'F'], 9 + _rnd.nextInt(3));

  static String _generate(List<String> faces, int length) {
    final out = <String>[];
    String? last;
    String? beforeLast;
    while (out.length < length) {
      final f = faces[_rnd.nextInt(faces.length)];
      if (f == last) continue;
      // avoid things like R L R (same axis three times in a row)
      if (last != null &&
          beforeLast != null &&
          _axis[f] == _axis[last] &&
          _axis[f] == _axis[beforeLast]) {
        continue;
      }
      if (last != null && beforeLast == f && _axis[f] == _axis[last]) continue;
      out.add(f + _suffixes[_rnd.nextInt(3)]);
      beforeLast = last;
      last = f;
    }
    return out.join(' ');
  }

  /// Random post-AUF so the same case does not always look identical.
  static String randomAuf() => const ['', 'U', "U'", 'U2'][_rnd.nextInt(4)];

  /// Appends an AUF, merging it with a trailing U turn ("R U" + "U" -> "R U2").
  static String withAuf(String scramble, String auf) {
    if (auf.isEmpty) return scramble;
    final t = scramble.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    int q(String s) => s.endsWith("'") ? 3 : (s.endsWith('2') ? 2 : 1);
    if (t.isNotEmpty && t.last[0] == 'U' && (t.last.length == 1 || !'w'.contains(t.last[1]))) {
      final n = (q(t.removeLast()) + q(auf)) % 4;
      if (n != 0) t.add(const ['', 'U', 'U2', "U'"][n]);
    } else {
      t.add(auf);
    }
    return t.join(' ');
  }

  /// Random practice scramble for a case. Avoids scrambles generated from the
  /// algorithm the user is learning ([avoidFrom]) when possible.
  static String forCase(List<String> scrambles, List<int> from, int avoidFrom, {bool auf = true}) {
    if (scrambles.isEmpty) return '';
    final idx = [
      for (var i = 0; i < scrambles.length; i++)
        if (i >= from.length || from[i] != avoidFrom) i,
    ];
    final pool = idx.isEmpty ? List.generate(scrambles.length, (i) => i) : idx;
    final s = scrambles[pool[_rnd.nextInt(pool.length)]];
    return auf ? withAuf(s, randomAuf()) : s;
  }
}
