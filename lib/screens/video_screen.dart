import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart';
import '../config.dart';
import '../theme.dart';
import 'home_shell.dart';

class YtVideo {
  final String id, title;
  final DateTime published;
  YtVideo(this.id, this.title, this.published);
  String get url => 'https://www.youtube.com/watch?v=$id';
  String get thumb => 'https://i.ytimg.com/vi/$id/hqdefault.jpg';
}

/// Latest videos from the TeluguTV YouTube channel (public RSS feed, no API key)
/// plus a LIVE button. Videos open in the YouTube app.
class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});
  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late Future<List<YtVideo>> _future = _load();

  Future<List<YtVideo>> _load() async {
    final res = await http.get(Uri.parse(
        'https://www.youtube.com/feeds/videos.xml?channel_id=${AppConfig.youtubeChannelId}'));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    final doc = XmlDocument.parse(res.body);
    return doc.findAllElements('entry').map((e) {
      final id = e.findElements('yt:videoId').first.innerText;
      final title = e.findElements('title').first.innerText;
      final pub = DateTime.tryParse(e.findElements('published').first.innerText) ?? DateTime.now();
      return YtVideo(id, title, pub);
    }).toList();
  }

  void _open(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: brandBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _future = _load());
          await _future.catchError((_) => <YtVideo>[]);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _open(AppConfig.youtubeLiveUrl),
                icon: const Icon(Icons.live_tv),
                label: const Text('TeluguTV LIVE చూడండి',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            FutureBuilder<List<YtVideo>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError || (snap.data ?? []).isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(children: [
                      const Text('వీడియోలు లోడ్ కాలేదు. ఇంటర్నెట్ చెక్ చేసి కిందకి లాగండి.'),
                      TextButton(
                        onPressed: () => _open(AppConfig.youtubeHandleUrl),
                        child: const Text('యూట్యూబ్ ఛానల్ తెరవండి'),
                      ),
                    ]),
                  );
                }
                return Column(
                  children: snap.data!.map((v) => _VideoTile(v: v, onTap: () => _open(v.url))).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final YtVideo v;
  final VoidCallback onTap;
  const _VideoTile({required this.v, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(fit: StackFit.expand, children: [
              CachedNetworkImage(imageUrl: v.thumb, fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(color: Brand.purpleDark)),
              const Center(child: Icon(Icons.play_circle_fill, size: 58, color: Colors.white70)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(v.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, height: 1.4)),
          ),
        ]),
      ),
    );
  }
}
