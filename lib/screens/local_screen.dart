import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../config.dart';
import '../data/news.dart';
import '../data/repository.dart';
import '../widgets/news_list_tile.dart';
import 'home_shell.dart';

class LocalScreen extends StatefulWidget {
  final List<News> news;
  const LocalScreen({super.key, required this.news});
  @override
  State<LocalScreen> createState() => _LocalScreenState();
}

class _LocalScreenState extends State<LocalScreen> {
  String _district = LocalPrefs.district;

  Future<void> _choose(String? d) async {
    final old = _district;
    final next = d ?? '';
    setState(() => _district = next);
    await LocalPrefs.setDistrict(next);
    if (AppConfig.firebaseEnabled) {
      try {
        final fm = FirebaseMessaging.instance;
        if (old.isNotEmpty) await fm.unsubscribeFromTopic(districtTopic(old));
        if (next.isNotEmpty) await fm.subscribeToTopic(districtTopic(next));
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.news.where((n) => _district.isEmpty || n.district == _district).toList();
    return Scaffold(
      appBar: brandBar(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              value: _district,
              decoration: const InputDecoration(
                labelText: 'మీ జిల్లా',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('అన్ని జిల్లాలు')),
                ...districts.map((d) => DropdownMenuItem(value: d, child: Text(d))),
              ],
              onChanged: _choose,
            ),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text('ఈ జిల్లా నుంచి ఇంకా వార్తలు లేవు')),
            ),
          ...items.map((n) => NewsListTile(news: n)),
        ],
      ),
    );
  }
}
