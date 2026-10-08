import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const _prefix = 'fav_';

  Future<Set<String>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    return keys.map((k) => k.substring(_prefix.length)).toSet();
  }

  Future<void> toggle(String name, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      await prefs.setBool('$_prefix$name', true);
    } else {
      await prefs.remove('$_prefix$name');
    }
  }
}