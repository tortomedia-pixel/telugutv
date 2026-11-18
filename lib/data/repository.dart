import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'news.dart';
import 'sample_news.dart';

/// Reads published news from Firestore (collection "news"),
/// or sample stories when Firebase isn't configured yet.
class NewsRepository {
  Stream<List<News>> watchNews() {
    if (!AppConfig.firebaseEnabled) {
      return Stream.value(sampleNews());
    }
    return FirebaseFirestore.instance
        .collection('news')
        .where('published', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(200)
        .snapshots()
        .map((s) => s.docs.map(News.fromDoc).toList());
  }
}

/// Saved stories and chosen district, stored on the phone.
class LocalPrefs {
  static late SharedPreferences _p;
  static Future<void> init() async => _p = await SharedPreferences.getInstance();

  static Set<String> get saved => (_p.getStringList('saved') ?? []).toSet();
  static Set<String> get liked => (_p.getStringList('liked') ?? []).toSet();
  static String get district => _p.getString('district') ?? '';

  static bool toggleSaved(String id) => _toggle('saved', id);
  static bool toggleLiked(String id) => _toggle('liked', id);
  static Future<void> setDistrict(String d) => _p.setString('district', d);

  static bool _toggle(String key, String id) {
    final s = (_p.getStringList(key) ?? []).toSet();
    final on = !s.remove(id);
    if (on) s.add(id);
    _p.setStringList(key, s.toList());
    return on;
  }
}
