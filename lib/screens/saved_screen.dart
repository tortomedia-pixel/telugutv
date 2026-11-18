import 'package:flutter/material.dart';
import '../data/news.dart';
import '../data/repository.dart';
import '../widgets/news_list_tile.dart';
import 'home_shell.dart';

class SavedScreen extends StatefulWidget {
  final List<News> news;
  const SavedScreen({super.key, required this.news});
  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  @override
  Widget build(BuildContext context) {
    final ids = LocalPrefs.saved;
    final items = widget.news.where((n) => ids.contains(n.id)).toList();
    return Scaffold(
      appBar: brandBar(actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: () => setState(() {})),
      ]),
      body: items.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('ఇంకా ఏ వార్తా సేవ్ చేయలేదు.\nవార్త కింద “సేవ్” నొక్కండి.',
                    textAlign: TextAlign.center, style: TextStyle(height: 1.7)),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: items
                    .map((n) => NewsListTile(news: n, onReturn: () => setState(() {})))
                    .toList(),
              ),
            ),
    );
  }
}
