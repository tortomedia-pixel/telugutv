import 'package:flutter/material.dart';
import '../data/news.dart';
import '../data/repository.dart';
import '../theme.dart';
import 'feed_screen.dart';
import 'local_screen.dart';
import 'saved_screen.dart';
import 'video_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _repo = NewsRepository();
  late final Stream<List<News>> _stream = _repo.watchNews().asBroadcastStream();
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<News>>(
      stream: _stream,
      builder: (context, snap) {
        final news = snap.data ?? const <News>[];
        final loading = !snap.hasData && !snap.hasError;
        final pages = [
          FeedScreen(news: news, loading: loading),
          LocalScreen(news: news),
          const VideoScreen(),
          SavedScreen(news: news),
        ];
        return Scaffold(
          body: IndexedStack(index: _tab, children: pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.article_outlined), selectedIcon: Icon(Icons.article, color: Brand.purple), label: 'వార్తలు'),
              NavigationDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on, color: Brand.purple), label: 'లోకల్'),
              NavigationDestination(icon: Icon(Icons.smart_display_outlined), selectedIcon: Icon(Icons.smart_display, color: Brand.purple), label: 'వీడియో'),
              NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark, color: Brand.purple), label: 'సేవ్'),
            ],
          ),
        );
      },
    );
  }
}

/// Header used on every tab: logo on dark purple with a gold line.
PreferredSizeWidget brandBar({List<Widget>? actions, PreferredSizeWidget? bottom}) {
  return AppBar(
    toolbarHeight: 60,
    titleSpacing: 12,
    title: Image.asset('assets/images/logo.png', height: 44),
    actions: actions,
    bottom: bottom,
    shape: const Border(bottom: BorderSide(color: Brand.gold, width: 3)),
  );
}
