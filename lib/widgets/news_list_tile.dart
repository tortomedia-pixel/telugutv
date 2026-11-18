import 'package:flutter/material.dart';
import '../data/news.dart';
import '../theme.dart';
import 'news_card.dart';

/// Compact row used in Local and Saved lists. Tapping opens the full card.
class NewsListTile extends StatelessWidget {
  final News news;
  final VoidCallback? onReturn;
  const NewsListTile({super.key, required this.news, this.onReturn});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: Text(news.categoryName)),
              body: NewsCard(news: news),
            ),
          ));
          onReturn?.call();
        },
        child: Row(children: [
          SizedBox(width: 96, height: 76, child: NewsImage(news: news)),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.4)),
                const SizedBox(height: 4),
                Text('${news.district} · ${news.timeAgo}',
                    style: const TextStyle(fontSize: 11, color: Brand.muted)),
              ]),
            ),
          ),
          const SizedBox(width: 8),
        ]),
      ),
    );
  }
}
