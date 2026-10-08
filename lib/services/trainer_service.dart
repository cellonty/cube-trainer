import 'package:shared_preferences/shared_preferences.dart';

class TrainerService {
  static const _prefix = 'trainer_';

  Future<void> addTime(String name, int ms) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix$name';
    final list = prefs.getStringList(key) ?? [];
    list.add(ms.toString());
    if (list.length > 50) list.removeRange(0, list.length - 50);
    await prefs.setStringList(key, list);
  }

  Future<List<int>> getTimes(String name) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('$_prefix$name') ?? [];
    return raw.map((s) => int.tryParse(s) ?? 0).where((v) => v > 0).toList();
  }

  Future<void> clearTimes(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$name');
  }
}