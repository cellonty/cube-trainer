import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/alg_data.dart';
import '../l10n/app_localizations.dart';
import '../logic/stats.dart';
import '../models/alg_models.dart';
import '../models/rubiks_cube.dart';

/// Fast lookups over the generated algorithm data.
class AlgRepo {
  static final Map<String, AlgCase> byId = {
    for (final s in kAlgSets)
      for (final c in s.cases) c.id: c,
  };
  static final Map<String, AlgSet> setOfCase = {
    for (final s in kAlgSets)
      for (final c in s.cases) c.id: s,
  };
  static AlgSet set(String id) => kAlgSets.firstWhere((s) => s.id == id);
  static List<AlgSet> byMethod(Method m) => kAlgSets.where((s) => s.method == m).toList();

  static final Map<String, RubiksCube> _cubes = {};

  /// Cube showing the case (cached, do not mutate).
  static RubiksCube caseCube(AlgCase c) =>
      _cubes.putIfAbsent(c.id, () => RubiksCube()..applyScramble(c.setup));
}

/// All persistent app state. Keys are compatible with the previous version
/// of the app (fav_<name>, trainer_<name>, language).
class AppState extends ChangeNotifier {
  AppState(this._p) {
    _load();
  }

  static Future<AppState> create() async => AppState(await SharedPreferences.getInstance());

  final SharedPreferences _p;

  ThemeMode themeMode = ThemeMode.system;
  String language = 'en';
  bool grayscale = false;
  bool inspection = true;
  int accent = 0;
  int holdMs = 300;

  final Set<String> favorites = {};
  final Map<String, LearnStatus> _status = {};
  List<Session> sessions = [];
  String currentSessionId = '';

  void _load() {
    final tm = _p.getInt('theme_mode');
    if (tm != null) {
      themeMode = ThemeMode.values[tm.clamp(0, 2)];
    } else if (_p.containsKey('theme_dark')) {
      themeMode = (_p.getBool('theme_dark') ?? false) ? ThemeMode.dark : ThemeMode.light;
    }
    language = _p.getString('language') ?? _deviceLanguage();
    if (!AppLocalizations.supportedCodes.contains(language)) language = 'en';
    grayscale = _p.getBool('grayscale') ?? false;
    inspection = _p.getBool('inspection') ?? true;
    accent = _p.getInt('accent') ?? 0;
    holdMs = _p.getInt('hold_ms') ?? 300;

    for (final k in _p.getKeys()) {
      if (k.startsWith('fav_')) favorites.add(k.substring(4));
      if (k.startsWith('status_')) {
        final v = _p.getInt(k) ?? 0;
        _status[k.substring(7)] = LearnStatus.values[v.clamp(0, 2)];
      }
    }

    sessions = Session.decodeAll(_p.getString('timer_sessions'));
    if (sessions.isEmpty) {
      sessions = [Session(id: _newId(), name: '3x3 #1', puzzle: '333')];
      _saveSessions();
    }
    currentSessionId = _p.getString('timer_current') ?? sessions.first.id;
    if (!sessions.any((s) => s.id == currentSessionId)) currentSessionId = sessions.first.id;
  }

  static String _deviceLanguage() {
    try {
      return WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    } catch (_) {
      return 'en';
    }
  }

  static String _newId() => DateTime.now().microsecondsSinceEpoch.toRadixString(36);

  // ---------------- settings ----------------
  void setThemeMode(ThemeMode m) {
    themeMode = m;
    _p.setInt('theme_mode', m.index);
    notifyListeners();
  }

  void setLanguage(String code) {
    language = code;
    _p.setString('language', code);
    notifyListeners();
  }

  void setGrayscale(bool v) {
    grayscale = v;
    _p.setBool('grayscale', v);
    notifyListeners();
  }

  void setInspection(bool v) {
    inspection = v;
    _p.setBool('inspection', v);
    notifyListeners();
  }

  void setAccent(int i) {
    accent = i;
    _p.setInt('accent', i);
    notifyListeners();
  }

  void setHoldMs(int v) {
    holdMs = v;
    _p.setInt('hold_ms', v);
    notifyListeners();
  }

  // ---------------- cases ----------------
  bool isFavorite(String id) => favorites.contains(id);

  void toggleFavorite(String id) {
    if (favorites.remove(id)) {
      _p.remove('fav_$id');
    } else {
      favorites.add(id);
      _p.setBool('fav_$id', true);
    }
    notifyListeners();
  }

  LearnStatus status(String id) => _status[id] ?? LearnStatus.notLearned;

  void setStatus(String id, LearnStatus s) {
    _status[id] = s;
    _p.setInt('status_$id', s.index);
    notifyListeners();
  }

  int countStatus(AlgSet set, LearnStatus s) => set.cases.where((c) => status(c.id) == s).length;

  List<String> customAlgs(String id) => _p.getStringList('custom_$id') ?? const [];

  void addCustomAlg(String id, String alg) {
    final l = [...customAlgs(id)];
    if (!l.contains(alg)) l.add(alg);
    _p.setStringList('custom_$id', l);
    notifyListeners();
  }

  void removeCustomAlg(String id, String alg) {
    final l = [...customAlgs(id)]..remove(alg);
    _p.setStringList('custom_$id', l);
    if (_p.getString('main_$id') == alg) _p.remove('main_$id');
    notifyListeners();
  }

  /// The algorithm the user chose for this case (defaults to the first verified one).
  String mainAlg(AlgCase c) {
    final m = _p.getString('main_${c.id}');
    if (m != null && (c.algs.contains(m) || customAlgs(c.id).contains(m))) return m;
    return c.algs.first;
  }

  void setMainAlg(String id, String alg) {
    _p.setString('main_$id', alg);
    notifyListeners();
  }

  String note(String id) => _p.getString('note_$id') ?? '';

  void setNote(String id, String text) {
    if (text.trim().isEmpty) {
      _p.remove('note_$id');
    } else {
      _p.setString('note_$id', text);
    }
  }

  // ---------------- case trainer times ----------------
  List<int> times(String id) => (_p.getStringList('trainer_$id') ?? const [])
      .map((s) => int.tryParse(s) ?? 0)
      .where((v) => v > 0)
      .toList();

  void addTime(String id, int ms) {
    final l = [...(_p.getStringList('trainer_$id') ?? const <String>[]), ms.toString()];
    if (l.length > 50) l.removeRange(0, l.length - 50);
    _p.setStringList('trainer_$id', l);
    notifyListeners();
  }

  void clearTimes(String id) {
    _p.remove('trainer_$id');
    notifyListeners();
  }

  double? avgTime(String id) {
    final t = times(id);
    if (t.isEmpty) return null;
    final last = t.length > 12 ? t.sublist(t.length - 12) : t;
    return last.reduce((a, b) => a + b) / last.length;
  }

  // ---------------- timer sessions ----------------
  Session get currentSession => sessions.firstWhere((s) => s.id == currentSessionId);

  void _saveSessions() {
    _p.setString('timer_sessions', Session.encodeAll(sessions));
    _p.setString('timer_current', currentSessionId);
  }

  void selectSession(String id) {
    currentSessionId = id;
    _saveSessions();
    notifyListeners();
  }

  void createSession(String name, String puzzle) {
    final s = Session(id: _newId(), name: name, puzzle: puzzle);
    sessions.add(s);
    currentSessionId = s.id;
    _saveSessions();
    notifyListeners();
  }

  void renameSession(String id, String name) {
    sessions.firstWhere((s) => s.id == id).name = name;
    _saveSessions();
    notifyListeners();
  }

  void deleteSession(String id) {
    if (sessions.length <= 1) {
      sessions.first.solves.clear();
    } else {
      sessions.removeWhere((s) => s.id == id);
      if (currentSessionId == id) currentSessionId = sessions.first.id;
    }
    _saveSessions();
    notifyListeners();
  }

  void addSolve(Solve s) {
    currentSession.solves.add(s);
    _saveSessions();
    notifyListeners();
  }

  void setPenalty(Solve s, Penalty p) {
    s.penalty = p;
    _saveSessions();
    notifyListeners();
  }

  void deleteSolve(Solve s) {
    currentSession.solves.remove(s);
    _saveSessions();
    notifyListeners();
  }
}

/// Provides [AppState] to the widget tree.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
