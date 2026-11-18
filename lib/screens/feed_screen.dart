import 'package:flutter/material.dart';
import '../data/news.dart';
import '../data/reporter.dart';
import 'post_screen.dart';
import '../theme.dart';
import '../widgets/news_card.dart';
import 'home_shell.dart';

class FeedScreen extends StatefulWidget {
  final List<News> news;
  final bool loading;
  const FeedScreen({super.key, required this.news, required this.loading});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  String _cat = 'all';
  String _query = '';
  bool _searching = false;
  final _pager = PageController();

  List<News> get _items => widget.news
      .where((n) => _cat == 'all' || n.category == _cat)
      .where((n) => _query.isEmpty ||
          n.title.contains(_query) || n.body.contains(_query) || n.district.contains(_query))
      .toList();

  void _setCat(String c) {
    setState(() => _cat = c);
    if (_pager.hasClients) _pager.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: Reporter.isReporter,
        builder: (context, isReporter, _) => isReporter
            ? FloatingActionButton.extended(
                backgroundColor: Brand.gold,
                foregroundColor: Brand.purpleDark,
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const PostScreen())),
                icon: const Icon(Icons.add),
                label: const Text('పోస్ట్', style: TextStyle(fontWeight: FontWeight.w700)),
              )
            : const SizedBox.shrink(),
      ),
      appBar: brandBar(
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) _query = '';
            }),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_searching ? 104 : 52),
          child: Column(children: [
            if (_searching)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: TextField(
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v.trim()),
                  decoration: const InputDecoration(
                    hintText: 'వార్తలు వెతకండి...',
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: categories.entries.map((e) {
                  final on = e.key == _cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6, bottom: 8),
                    child: GestureDetector(
                      onTap: () => _setCat(e.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: on ? Brand.gold : Colors.white.withOpacity(.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          e.value,
                          style: TextStyle(
                            color: on ? Brand.purpleDark : Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ]),
        ),
      ),
      body: widget.loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text('ఈ విభాగంలో వార్తలు లేవు'))
              : PageView.builder(
                  controller: _pager,
                  scrollDirection: Axis.vertical,
                  itemCount: items.length,
                  itemBuilder: (_, i) => NewsCard(news: items[i]),
                ),
    );
  }
}
