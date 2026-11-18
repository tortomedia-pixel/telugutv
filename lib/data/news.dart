import 'package:cloud_firestore/cloud_firestore.dart';

const categories = <String, String>{
  'all': 'అన్నీ',
  'ap': 'ఆంధ్రప్రదేశ్',
  'ts': 'తెలంగాణ',
  'national': 'జాతీయం',
  'cinema': 'సినిమా',
  'sports': 'క్రీడలు',
  'business': 'బిజినెస్',
  'tech': 'టెక్',
  'devotional': 'భక్తి',
};

const districts = <String>[
  'శ్రీకాకుళం', 'విజయనగరం', 'విశాఖపట్నం', 'కాకినాడ', 'రాజమహేంద్రవరం',
  'ఏలూరు', 'విజయవాడ', 'అమరావతి', 'గుంటూరు', 'ఒంగోలు', 'నెల్లూరు',
  'తిరుపతి', 'చిత్తూరు', 'కడప', 'కర్నూలు', 'అనంతపురం', 'హైదరాబాద్', 'వరంగల్',
];

/// Push-notification topic for a district (must match functions/index.js).
String districtTopic(String d) => 'district_${districts.indexOf(d)}';

class News {
  final String id;
  final String title;
  final String body;
  final String category;
  final String district;
  final String reporter;
  final String imageUrl;
  final String videoUrl;
  final DateTime createdAt;

  const News({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.district,
    required this.reporter,
    required this.createdAt,
    this.imageUrl = '',
    this.videoUrl = '',
  });

  factory News.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    final ts = m['createdAt'];
    return News(
      id: d.id,
      title: (m['title'] ?? '') as String,
      body: (m['body'] ?? '') as String,
      category: (m['category'] ?? 'ap') as String,
      district: (m['district'] ?? '') as String,
      reporter: (m['reporter'] ?? 'TeluguTV Desk') as String,
      imageUrl: (m['imageUrl'] ?? '') as String,
      videoUrl: (m['videoUrl'] ?? '') as String,
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }

  String get categoryName => categories[category] ?? category;

  String get timeAgo {
    final m = DateTime.now().difference(createdAt).inMinutes;
    if (m < 1) return 'ఇప్పుడే';
    if (m < 60) return '$m నిమి. క్రితం';
    if (m < 1440) return '${m ~/ 60} గం. క్రితం';
    return '${m ~/ 1440} రోజుల క్రితం';
  }
}
