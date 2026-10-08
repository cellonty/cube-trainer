class RubiksCube {
  final Map<String, List<String>> f;

  RubiksCube()
      : f = {
          'U': List.filled(9, 'Y'),
          'D': List.filled(9, 'W'),
          'F': List.filled(9, 'G'),
          'B': List.filled(9, 'B'),
          'R': List.filled(9, 'O'),
          'L': List.filled(9, 'R'),
        };

  RubiksCube._clone(this.f);

  RubiksCube clone() => RubiksCube._clone({
        for (final e in f.entries) e.key: List<String>.from(e.value),
      });

  void applyScramble(String scramble) {
    for (final m in scramble.trim().split(RegExp(r'\s+'))) {
      if (m.isNotEmpty) applyMove(m);
    }
  }

  void applyMove(String move) {
    if (move.isEmpty) return;

    String base = move;
    String suffix = '';

    if (move.endsWith("2'")) {
      base = move.substring(0, move.length - 2);
      suffix = '2';
    } else if (move.endsWith("'")) {
      base = move.substring(0, move.length - 1);
      suffix = "'";
    } else if (move.endsWith('2')) {
      base = move.substring(0, move.length - 1);
      suffix = '2';
    }

    if (base.length == 2 && base.endsWith('w')) {
      final c = base[0];
      if (c == 'R') {
        base = 'r';
      } else if (c == 'L') {
        base = 'l';
      } else if (c == 'U') {
        base = 'u';
      } else if (c == 'D') {
        base = 'd';
      } else if (c == 'F') {
        base = 'f';
      } else if (c == 'B') {
        base = 'b';
      }
    }

    int times;
    if (suffix == '2') {
      times = 2;
    } else if (suffix == "'") {
      times = 3;
    } else {
      times = 1;
    }

    for (var i = 0; i < times; i++) {
      switch (base) {
        case 'U':
          _uTurn();
          break;
        case 'D':
          _dTurn();
          break;
        case 'L':
          _lTurn();
          break;
        case 'R':
          _rTurn();
          break;
        case 'F':
          _fTurn();
          break;
        case 'B':
          _bTurn();
          break;
        case 'M':
          _mSlice();
          break;
        case 'E':
          _eSlice();
          break;
        case 'S':
          _sSlice();
          break;
        case 'r':
          _rTurn();
          _mSlice();
          _mSlice();
          _mSlice();
          break;
        case 'l':
          _lTurn();
          _mSlice();
          break;
        case 'u':
          _uTurn();
          _eSlice();
          _eSlice();
          _eSlice();
          break;
        case 'd':
          _dTurn();
          _eSlice();
          break;
        case 'f':
          _fTurn();
          _sSlice();
          break;
        case 'b':
          _bTurn();
          _sSlice();
          _sSlice();
          _sSlice();
          break;
        case 'x':
          _xRot();
          break;
        case 'y':
          _yRot();
          break;
        case 'z':
          _zRot();
          break;
      }
    }
  }

  void _uTurn() {
    final u = f['U']!, ff = f['F']!, r = f['R']!, b = f['B']!, l = f['L']!;
    f['U'] = [u[6], u[3], u[0], u[7], u[4], u[1], u[8], u[5], u[2]];
    f['F'] = [r[0], r[1], r[2], ff[3], ff[4], ff[5], ff[6], ff[7], ff[8]];
    f['R'] = [b[0], b[1], b[2], r[3], r[4], r[5], r[6], r[7], r[8]];
    f['B'] = [l[0], l[1], l[2], b[3], b[4], b[5], b[6], b[7], b[8]];
    f['L'] = [ff[0], ff[1], ff[2], l[3], l[4], l[5], l[6], l[7], l[8]];
  }

  void _dTurn() {
    final d = f['D']!, ff = f['F']!, r = f['R']!, b = f['B']!, l = f['L']!;
    f['D'] = [d[6], d[3], d[0], d[7], d[4], d[1], d[8], d[5], d[2]];
    f['F'] = [ff[0], ff[1], ff[2], ff[3], ff[4], ff[5], l[6], l[7], l[8]];
    f['R'] = [r[0], r[1], r[2], r[3], r[4], r[5], ff[6], ff[7], ff[8]];
    f['B'] = [b[0], b[1], b[2], b[3], b[4], b[5], r[6], r[7], r[8]];
    f['L'] = [l[0], l[1], l[2], l[3], l[4], l[5], b[6], b[7], b[8]];
  }

  void _rTurn() {
    final u = f['U']!, ff = f['F']!, r = f['R']!, d = f['D']!, b = f['B']!;
    f['R'] = [r[6], r[3], r[0], r[7], r[4], r[1], r[8], r[5], r[2]];
    f['U'] = [u[0], u[1], ff[2], u[3], u[4], ff[5], u[6], u[7], ff[8]];
    f['F'] = [ff[0], ff[1], d[2], ff[3], ff[4], d[5], ff[6], ff[7], d[8]];
    f['D'] = [d[0], d[1], b[6], d[3], d[4], b[3], d[6], d[7], b[0]];
    f['B'] = [u[8], b[1], b[2], u[5], b[4], b[5], u[2], b[7], b[8]];
  }

  void _lTurn() {
    final u = f['U']!, ff = f['F']!, l = f['L']!, d = f['D']!, b = f['B']!;
    f['L'] = [l[6], l[3], l[0], l[7], l[4], l[1], l[8], l[5], l[2]];
    f['U'] = [b[8], u[1], u[2], b[5], u[4], u[5], b[2], u[7], u[8]];
    f['F'] = [u[0], ff[1], ff[2], u[3], ff[4], ff[5], u[6], ff[7], ff[8]];
    f['D'] = [ff[0], d[1], d[2], ff[3], d[4], d[5], ff[6], d[7], d[8]];
    f['B'] = [b[0], b[1], d[6], b[3], b[4], d[3], b[6], b[7], d[0]];
  }

  void _fTurn() {
    final u = f['U']!, ff = f['F']!, r = f['R']!, d = f['D']!, l = f['L']!;
    f['F'] = [ff[6], ff[3], ff[0], ff[7], ff[4], ff[1], ff[8], ff[5], ff[2]];
    f['U'] = [u[0], u[1], u[2], u[3], u[4], u[5], l[8], l[5], l[2]];
    f['R'] = [u[6], r[1], r[2], u[7], r[4], r[5], u[8], r[7], r[8]];
    f['D'] = [r[6], r[3], r[0], d[3], d[4], d[5], d[6], d[7], d[8]];
    f['L'] = [l[0], l[1], d[0], l[3], l[4], d[1], l[6], l[7], d[2]];
  }

  void _bTurn() {
    final u = f['U']!, b = f['B']!, r = f['R']!, d = f['D']!, l = f['L']!;
    f['B'] = [b[6], b[3], b[0], b[7], b[4], b[1], b[8], b[5], b[2]];
    f['U'] = [r[2], r[5], r[8], u[3], u[4], u[5], u[6], u[7], u[8]];
    f['L'] = [u[2], l[1], l[2], u[1], l[4], l[5], u[0], l[7], l[8]];
    f['D'] = [d[0], d[1], d[2], d[3], d[4], d[5], l[0], l[3], l[6]];
    f['R'] = [r[0], r[1], d[8], r[3], r[4], d[7], r[6], r[7], d[6]];
  }

  void _mSlice() {
    final u = f['U']!, ff = f['F']!, d = f['D']!, b = f['B']!;
    f['U'] = [u[0], b[7], u[2], u[3], b[4], u[5], u[6], b[1], u[8]];
    f['F'] = [ff[0], u[1], ff[2], ff[3], u[4], ff[5], ff[6], u[7], ff[8]];
    f['D'] = [d[0], ff[1], d[2], d[3], ff[4], d[5], d[6], ff[7], d[8]];
    f['B'] = [b[0], d[7], b[2], b[3], d[4], b[5], b[6], d[1], b[8]];
  }

  void _eSlice() {
    final ff = f['F']!, r = f['R']!, b = f['B']!, l = f['L']!;
    f['F'] = [ff[0], ff[1], ff[2], l[3], l[4], l[5], ff[6], ff[7], ff[8]];
    f['R'] = [r[0], r[1], r[2], ff[3], ff[4], ff[5], r[6], r[7], r[8]];
    f['B'] = [b[0], b[1], b[2], r[3], r[4], r[5], b[6], b[7], b[8]];
    f['L'] = [l[0], l[1], l[2], b[3], b[4], b[5], l[6], l[7], l[8]];
  }

  void _sSlice() {
    final u = f['U']!, r = f['R']!, d = f['D']!, l = f['L']!;
    f['U'] = [u[0], u[1], u[2], l[7], l[4], l[1], u[6], u[7], u[8]];
    f['R'] = [r[0], u[3], r[2], r[3], u[4], r[5], r[6], u[5], r[8]];
    f['D'] = [d[0], d[1], d[2], r[7], r[4], r[1], d[6], d[7], d[8]];
    f['L'] = [l[0], d[3], l[2], l[3], d[4], l[5], l[6], d[5], l[8]];
  }

  void _xRot() {
    final u = f['U']!, ff = f['F']!, d = f['D']!, b = f['B']!;
    final r = f['R']!, l = f['L']!;

    f['U'] = List<String>.from(ff);
    f['B'] = [u[8], u[7], u[6], u[5], u[4], u[3], u[2], u[1], u[0]];
    f['D'] = [b[8], b[7], b[6], b[5], b[4], b[3], b[2], b[1], b[0]];
    f['F'] = List<String>.from(d);

    f['R'] = [r[6], r[3], r[0], r[7], r[4], r[1], r[8], r[5], r[2]];
    f['L'] = [l[2], l[5], l[8], l[1], l[4], l[7], l[0], l[3], l[6]];
  }

  void _yRot() {
    final u = f['U']!, ff = f['F']!, d = f['D']!;
    final b = f['B']!, r = f['R']!, l = f['L']!;
    f['F'] = List<String>.from(r);
    f['R'] = List<String>.from(b);
    f['B'] = List<String>.from(l);
    f['L'] = List<String>.from(ff);
    f['U'] = [u[6], u[3], u[0], u[7], u[4], u[1], u[8], u[5], u[2]];
    f['D'] = [d[2], d[5], d[8], d[1], d[4], d[7], d[0], d[3], d[6]];
  }

  void _zRot() {
    final u = f['U']!, ff = f['F']!, r = f['R']!, d = f['D']!;
    final l = f['L']!, b = f['B']!;
    f['R'] = [u[6], u[3], u[0], u[7], u[4], u[1], u[8], u[5], u[2]];
    f['D'] = [r[6], r[3], r[0], r[7], r[4], r[1], r[8], r[5], r[2]];
    f['L'] = [d[6], d[3], d[0], d[7], d[4], d[1], d[8], d[5], d[2]];
    f['U'] = [l[6], l[3], l[0], l[7], l[4], l[1], l[8], l[5], l[2]];
    f['F'] = [ff[6], ff[3], ff[0], ff[7], ff[4], ff[1], ff[8], ff[5], ff[2]];
    f['B'] = [b[2], b[5], b[8], b[1], b[4], b[7], b[0], b[3], b[6]];
  }

  List<List<int>> computePllArrows() {
    final arrows = <List<int>>[];

    final cornerHome = <String, int>{
      'G,O,Y': 8,
      'G,R,Y': 6,
      'B,R,Y': 0,
      'B,O,Y': 2,
    };

    for (final slot in [8, 6, 0, 2]) {
      final colors = _cornerColorsAtU(slot);
      final key = _sortedKey(colors);
      final home = cornerHome[key];
      if (home != null && home != slot) {
        arrows.add([slot, home]);
      }
    }

    final edgeHome = <String, int>{
      'G,Y': 7,
      'O,Y': 5,
      'B,Y': 1,
      'R,Y': 3,
    };

    for (final slot in [7, 5, 1, 3]) {
      final colors = _edgeColorsAtU(slot);
      final key = _sortedKey(colors);
      final home = edgeHome[key];
      if (home != null && home != slot) {
        arrows.add([slot, home]);
      }
    }

    final result = <List<int>>[];
    final used = <String>{};
    for (final a in arrows) {
      final fwd = '${a[0]}->${a[1]}';
      final rev = '${a[1]}->${a[0]}';
      if (used.contains(rev) || used.contains(fwd)) continue;
      used.add(fwd);
      result.add(a);
    }

    return result;
  }

  Set<String> _cornerColorsAtU(int uIdx) {
    switch (uIdx) {
      case 8:
        return {f['U']![8], f['F']![2], f['R']![0]};
      case 6:
        return {f['U']![6], f['F']![0], f['L']![2]};
      case 0:
        return {f['U']![0], f['B']![2], f['L']![0]};
      case 2:
        return {f['U']![2], f['B']![0], f['R']![2]};
    }
    return {};
  }

  Set<String> _edgeColorsAtU(int uIdx) {
    switch (uIdx) {
      case 7:
        return {f['U']![7], f['F']![1]};
      case 5:
        return {f['U']![5], f['R']![1]};
      case 1:
        return {f['U']![1], f['B']![1]};
      case 3:
        return {f['U']![3], f['L']![1]};
    }
    return {};
  }

  String _sortedKey(Set<String> s) {
    final list = s.toList()..sort();
    return list.join(',');
  }

  static const Map<String, List<String>> _cornerPositions = {
    'UFR': ['U,8', 'F,2', 'R,0'],
    'UFL': ['U,6', 'F,0', 'L,2'],
    'UBR': ['U,2', 'B,0', 'R,2'],
    'UBL': ['U,0', 'B,2', 'L,0'],
    'DFR': ['D,2', 'F,8', 'R,6'],
    'DFL': ['D,0', 'F,6', 'L,8'],
    'DBR': ['D,8', 'B,6', 'R,8'],
    'DBL': ['D,6', 'B,8', 'L,6'],
  };

  static const Map<String, List<String>> _edgePositions = {
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

  String _colorAt(String coord) {
    final parts = coord.split(',');
    return f[parts[0]]![int.parse(parts[1])];
  }

  Set<String> f2lRelevantStickers() {
    const targetCorner = {'W', 'G', 'O'};
    const targetEdge = {'G', 'O'};
    final result = <String>{};

    for (final face in ['U', 'D', 'F', 'B', 'R', 'L']) {
      result.add('$face,4');
    }

    for (final entry in _cornerPositions.entries) {
      final colors = entry.value.map(_colorAt).toSet();
      if (colors.length == 3 && colors.containsAll(targetCorner)) {
        result.addAll(entry.value);
      }
    }

    for (final entry in _edgePositions.entries) {
      final colors = entry.value.map(_colorAt).toSet();
      if (colors.length == 2 && colors.containsAll(targetEdge)) {
        result.addAll(entry.value);
      }
    }

    return result;
  }
}