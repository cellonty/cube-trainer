import '../models/alg_models.dart';
import '../models/rubiks_cube.dart';

/// Helpers for move notation.
class AlgTools {
  static final RegExp _token =
      RegExp(r"^(?:[UDFBRL]w?|[udfbrlMESxyz])(?:2'|2|')?$");
  static final RegExp _twoByTwoBad = RegExp(r'^[udfbrlMES]|^[UDFBRL]w');

  /// Removes brackets, normalises quote characters and whitespace.
  static String clean(String alg) {
    final s = alg
        .replaceAll('\u2019', "'")
        .replaceAll('\u2032', "'")
        .replaceAll('`', "'")
        .replaceAll(RegExp(r'[()\[\]{}]'), ' ');
    return tokens(s).join(' ');
  }

  static List<String> tokens(String alg) => alg
      .trim()
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();

  /// Returns the first invalid token, or null when every token is valid.
  static String? invalidToken(String alg, {bool twoByTwo = false}) {
    for (final t in tokens(alg)) {
      if (!_token.hasMatch(t)) return t;
      if (twoByTwo && _twoByTwoBad.hasMatch(t)) return t;
    }
    return null;
  }

  static String invertToken(String t) {
    if (t.endsWith("2'")) return t.substring(0, t.length - 1);
    if (t.endsWith('2')) return t;
    if (t.endsWith("'")) return t.substring(0, t.length - 1);
    return "$t'";
  }

  static String invert(String alg) =>
      tokens(alg).reversed.map(invertToken).join(' ');

  /// Move count without whole-cube rotations (HTM-ish, slices count as 1).
  static int moveCount(String alg) => tokens(alg)
      .where((t) => !(t.startsWith('x') || t.startsWith('y') || t.startsWith('z')))
      .length;

  /// Splits a token into base and number of clockwise quarter turns (1..3).
  static (String, int) split(String t) {
    var base = t;
    var times = 1;
    if (t.endsWith("2'")) {
      base = t.substring(0, t.length - 2);
      times = 2;
    } else if (t.endsWith("'")) {
      base = t.substring(0, t.length - 1);
      times = 3;
    } else if (t.endsWith('2')) {
      base = t.substring(0, t.length - 1);
      times = 2;
    }
    if (base.length == 2 && base.endsWith('w')) base = base[0].toLowerCase();
    return (base, times);
  }
}

/// Cube state checks. This is a 1:1 port of the predicates that were used
/// to verify the built-in algorithms (tools/verify/preds.py).
class CubeChecks {
  static const Map<String, String> solvedColor = {
    'U': 'Y',
    'D': 'W',
    'F': 'G',
    'B': 'B',
    'R': 'O',
    'L': 'R',
  };
  static const List<String> faces = ['U', 'D', 'F', 'B', 'R', 'L'];
  static const List<String> aufs = ['', 'U', "U'", 'U2'];
  static const List<int> ci = [0, 2, 6, 8];

  static const Map<String, List<String>> corners = {
    'UFR': ['U,8', 'F,2', 'R,0'],
    'UFL': ['U,6', 'F,0', 'L,2'],
    'UBR': ['U,2', 'B,0', 'R,2'],
    'UBL': ['U,0', 'B,2', 'L,0'],
    'DFR': ['D,2', 'F,8', 'R,6'],
    'DFL': ['D,0', 'F,6', 'L,8'],
    'DBR': ['D,8', 'B,6', 'R,8'],
    'DBL': ['D,6', 'B,8', 'L,6'],
  };
  static const Map<String, List<String>> edges = {
    'UF': ['U,7', 'F,1'],
    'UR': ['U,5', 'R,1'],
    'UB': ['U,1', 'B,1'],
    'UL': ['U,3', 'L,1'],
    'FR': ['F,5', 'R,3'],
    'FL': ['F,3', 'L,5'],
    'BR': ['B,3', 'R,5'],
    'BL': ['B,5', 'L,3'],
    'DF': ['D,1', 'F,7'],
    'DR': ['D,5', 'R,7'],
    'DB': ['D,7', 'B,7'],
    'DL': ['D,3', 'L,7'],
  };

  static final List<String> rot24 = [
    for (final a in ['', 'x', 'x2', "x'", 'z', "z'"])
      for (final b in ['', 'y', 'y2', "y'"]) '$a $b'.trim(),
  ];

  static String at(RubiksCube c, String s) {
    final i = s.indexOf(',');
    return c.f[s.substring(0, i)]![int.parse(s.substring(i + 1))];
  }

  static bool stickerOk(RubiksCube c, String s) =>
      at(c, s) == solvedColor[s.substring(0, 1)];

  static bool pieceOk(RubiksCube c, List<String> p) => p.every((s) => stickerOk(c, s));

  static bool isSolved(RubiksCube c) =>
      faces.every((f) => c.f[f]!.every((x) => x == solvedColor[f]));

  static RubiksCube applied(RubiksCube c, String moves) =>
      c.clone()..applyScramble(moves);

  static RubiksCube? normalize(RubiksCube c) {
    for (final r in rot24) {
      final g = applied(c, r);
      if (faces.every((f) => g.f[f]![4] == solvedColor[f])) return g;
    }
    return null;
  }

  static bool uptoAuf(RubiksCube c, bool Function(RubiksCube) pred) =>
      aufs.any((a) => pred(applied(c, a)));

  static bool f2lIntact(RubiksCube g) {
    if (g.f['D']!.any((x) => x != 'W')) return false;
    for (final fc in ['F', 'R', 'B', 'L']) {
      for (var i = 3; i < 9; i++) {
        if (g.f[fc]![i] != solvedColor[fc]) return false;
      }
    }
    return true;
  }

  static bool uAll(RubiksCube g) => g.f['U']!.every((x) => x == 'Y');
  static bool uEdges(RubiksCube g) => [1, 3, 5, 7].every((i) => g.f['U']![i] == 'Y');
  static bool llCornersOk(RubiksCube g) =>
      ['UFR', 'UFL', 'UBR', 'UBL'].every((k) => pieceOk(g, corners[k]!));

  static bool blocksOk(RubiksCube g) {
    for (var i = 3; i < 9; i++) {
      if (g.f['L']![i] != 'R' || g.f['R']![i] != 'O') return false;
    }
    for (final i in [0, 3, 6, 2, 5, 8]) {
      if (g.f['D']![i] != 'W') return false;
    }
    for (final i in [3, 6, 5, 8]) {
      if (g.f['F']![i] != 'G' || g.f['B']![i] != 'B') return false;
    }
    return true;
  }

  static RubiksCube? cmllOrient(RubiksCube c) {
    for (final r in rot24) {
      final g = applied(c, r);
      if (blocksOk(g)) return g;
    }
    return null;
  }

  static bool cornersUniform(RubiksCube g) =>
      faces.every((f) => ci.map((i) => g.f[f]![i]).toSet().length == 1);

  static int lseBad(RubiksCube g) {
    var n = 0;
    for (final e in ['UF', 'UB', 'UL', 'UR', 'DF', 'DB']) {
      final s = at(g, edges[e]![0]);
      if (s != 'Y' && s != 'W') n++;
    }
    return n;
  }

  /// Goal predicate for a case (state after the algorithm).
  static bool goalReached(CaseGoal goal, RubiksCube f) {
    switch (goal) {
      case CaseGoal.f2l:
        final g = normalize(f);
        return g != null && f2lIntact(g);
      case CaseGoal.oll:
      case CaseGoal.ocll:
        final g = normalize(f);
        return g != null && f2lIntact(g) && uAll(g);
      case CaseGoal.eo:
        final g = normalize(f);
        return g != null && f2lIntact(g) && uEdges(g);
      case CaseGoal.pll:
      case CaseGoal.ell:
      case CaseGoal.lseEp:
        final g = normalize(f);
        return g != null && uptoAuf(g, isSolved);
      case CaseGoal.coll:
        final g = normalize(f);
        return g != null && f2lIntact(g) && uAll(g) && uptoAuf(g, llCornersOk);
      case CaseGoal.cmll:
        final g = cmllOrient(f);
        return g != null && uptoAuf(g, llCornersOk);
      case CaseGoal.lseEo:
        final g = cmllOrient(f);
        return g != null &&
            uptoAuf(g, llCornersOk) &&
            (g.f['U']![4] == 'Y' || g.f['U']![4] == 'W') &&
            lseBad(g) == 0;
      case CaseGoal.cll:
      case CaseGoal.eg1:
      case CaseGoal.eg2:
      case CaseGoal.pbl:
        return uptoAuf(f, cornersUniform);
      case CaseGoal.ortegaOll:
        final g = normalize(f);
        return g != null &&
            ci.every((i) => g.f['U']![i] == 'Y') &&
            ci.every((i) => g.f['D']![i] == 'W');
    }
  }

  /// Does [alg] (optionally preceded by an AUF) solve the case created by [setup]?
  static bool solves(String setup, String alg, CaseGoal goal) {
    final start = RubiksCube()..applyScramble(setup);
    for (final a in aufs) {
      final c = start.clone()
        ..applyScramble(a)
        ..applyScramble(alg);
      if (goalReached(goal, c)) return true;
    }
    return false;
  }
}

/// Stickers that stay coloured in grayscale mode ("face,index" keys).
/// Returns null when everything is relevant.
class StickerMask {
  static Set<String>? forGoal(RubiksCube c, CaseGoal goal) {
    final out = <String>{};
    void centers(List<String> fs) {
      for (final f in fs) {
        out.add('$f,4');
      }
    }

    Set<String> colorsOf(List<String> piece) =>
        piece.map((s) => CubeChecks.at(c, s)).toSet();

    void piecesWhere(bool Function(Set<String>) test,
        {bool cornersOnly = false, bool edgesOnly = false}) {
      if (!edgesOnly) {
        for (final p in CubeChecks.corners.values) {
          if (test(colorsOf(p))) out.addAll(p);
        }
      }
      if (!cornersOnly) {
        for (final p in CubeChecks.edges.values) {
          if (test(colorsOf(p))) out.addAll(p);
        }
      }
    }

    void colored(Set<String> colors) {
      for (final f in CubeChecks.faces) {
        for (var i = 0; i < 9; i++) {
          if (colors.contains(c.f[f]![i])) out.add('$f,$i');
        }
      }
    }

    switch (goal) {
      case CaseGoal.f2l:
        centers(CubeChecks.faces);
        piecesWhere((s) => s.length == 3 && s.containsAll({'W', 'G', 'O'}), cornersOnly: true);
        piecesWhere((s) => s.length == 2 && s.containsAll({'G', 'O'}), edgesOnly: true);
        return out;
      case CaseGoal.oll:
      case CaseGoal.ocll:
        colored({'Y'});
        return out;
      case CaseGoal.eo:
        piecesWhere((s) => s.contains('Y'), edgesOnly: true);
        out.removeWhere((k) => CubeChecks.at(c, k) != 'Y');
        centers(['U']);
        return out;
      case CaseGoal.ortegaOll:
        colored({'Y', 'W'});
        return out;
      case CaseGoal.pll:
      case CaseGoal.coll:
        piecesWhere((s) => s.contains('Y'));
        centers(['U', 'F', 'R', 'B', 'L']);
        return out;
      case CaseGoal.ell:
        piecesWhere((s) => s.contains('Y'), edgesOnly: true);
        centers(['U', 'F', 'R', 'B', 'L']);
        return out;
      case CaseGoal.cmll:
      case CaseGoal.cll:
        piecesWhere((s) => s.contains('Y'), cornersOnly: true);
        return out;
      case CaseGoal.lseEo:
      case CaseGoal.lseEp:
        piecesWhere(
            (s) => s.contains('Y') || (s.contains('W') && (s.contains('G') || s.contains('B'))),
            edgesOnly: true);
        centers(['U', 'D', 'F', 'B']);
        return out;
      case CaseGoal.eg1:
      case CaseGoal.eg2:
      case CaseGoal.pbl:
        return null;
    }
  }
}
