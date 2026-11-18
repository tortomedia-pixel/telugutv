import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import '../data/news.dart';
import '../data/repository.dart';
import '../theme.dart';

/// One full-screen news card (image on top, 60-word story, action bar).
class NewsCard extends StatefulWidget {
  final News news;
  const NewsCard({super.key, required this.news});
  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  late bool _saved = LocalPrefs.saved.contains(widget.news.id);
  late bool _liked = LocalPrefs.liked.contains(widget.news.id);

  News get n => widget.news;

  void _share() {
    final video = n.videoUrl.isNotEmpty ? '\n\n▶ ${n.videoUrl}' : '';
    Share.share('${n.title}\n\n${n.body}$video\n\n${AppConfig.shareFooter}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(children: [
        Expanded(
          flex: 42,
          child: Stack(fit: StackFit.expand, children: [
            NewsImage(news: n),
            if (n.videoUrl.isNotEmpty)
              Center(
                child: IconButton.filled(
                  iconSize: 40,
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  onPressed: () => launchUrl(Uri.parse(n.videoUrl),
                      mode: LaunchMode.externalApplication),
                ),
              ),
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: Brand.gold, borderRadius: BorderRadius.circular(4)),
                child: Text(n.categoryName,
                    style: const TextStyle(color: Brand.purpleDark, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
        Expanded(
          flex: 58,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n.title,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.45, color: Brand.ink)),
              const SizedBox(height: 10),
              Expanded(
                child: Text(n.body,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(fontSize: 15.5, height: 1.75, color: Color(0xFF333333))),
              ),
              const SizedBox(height: 6),
              Text('${n.reporter} · ${n.district} · ${n.timeAgo}',
                  style: const TextStyle(fontSize: 12, color: Brand.muted)),
            ]),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _Action(
              icon: _liked ? Icons.favorite : Icons.favorite_border,
              label: 'లైక్',
              on: _liked,
              onTap: () => setState(() => _liked = LocalPrefs.toggleLiked(n.id)),
            ),
            _Action(icon: Icons.chat_outlined, label: 'వాట్సాప్', onTap: _share),
            _Action(icon: Icons.share_outlined, label: 'షేర్', onTap: _share),
            _Action(
              icon: _saved ? Icons.bookmark : Icons.bookmark_border,
              label: 'సేవ్',
              on: _saved,
              onTap: () {
                setState(() => _saved = LocalPrefs.toggleSaved(n.id));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(_saved ? 'సేవ్ అయింది' : 'తీసివేయబడింది'),
                  duration: const Duration(seconds: 1),
                ));
              },
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool on;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.onTap, this.on = false});

  @override
  Widget build(BuildContext context) {
    final c = on ? Brand.purple : Brand.muted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: c, size: 22),
          Text(label, style: TextStyle(fontSize: 11, color: c, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

/// Story photo, or a branded gradient when the story has no photo.
class NewsImage extends StatelessWidget {
  final News news;
  const NewsImage({super.key, required this.news});

  static const _palette = {
    'ap': [Color(0xFFE65100), Color(0xFFFFB74D)],
    'ts': [Color(0xFF6A1B9A), Color(0xFFCE93D8)],
    'national': [Color(0xFF1565C0), Color(0xFF90CAF9)],
    'cinema': [Color(0xFFAD1457), Color(0xFFF48FB1)],
    'sports': [Color(0xFF2E7D32), Color(0xFFA5D6A7)],
    'business': [Color(0xFF37474F), Color(0xFFB0BEC5)],
    'tech': [Color(0xFF00838F), Color(0xFF80DEEA)],
    'devotional': [Color(0xFFFF8F00), Color(0xFFFFE082)],
  };

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _palette[news.category] ?? const [Brand.purpleDark, Brand.purple],
        ),
      ),
      alignment: Alignment.center,
      child: Opacity(opacity: .9, child: Image.asset('assets/images/logo.png', width: 160)),
    );
    if (news.imageUrl.isEmpty) return placeholder;
    return CachedNetworkImage(
      imageUrl: news.imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => placeholder,
    );
  }
}
