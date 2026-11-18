import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/news.dart';
import '../data/reporter.dart';
import '../theme.dart';

/// Story publishing form. Reachable only after a reporter logs in.
class PostScreen extends StatefulWidget {
  const PostScreen({super.key});
  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _name = TextEditingController();
  final _video = TextEditingController();
  String _category = 'ap';
  String _district = districts.first;
  bool _notify = true;
  File? _photo;
  bool _busy = false;

  int get _words => _body.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  Future<void> _pick(ImageSource src) async {
    final x = await ImagePicker().pickImage(source: src, maxWidth: 1280, imageQuality: 80);
    if (x != null) setState(() => _photo = File(x.path));
  }

  Future<void> _publish() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await Reporter.publish(
        title: _title.text.trim(),
        body: _body.text.trim(),
        category: _category,
        district: _district,
        reporterName: _name.text.trim(),
        videoUrl: _video.text.trim(),
        notify: _notify,
        photo: _photo,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ వార్త పబ్లిష్ అయింది')));
      _title.clear();
      _body.clear();
      _video.clear();
      setState(() => _photo = null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ పబ్లిష్ కాలేదు: $e')));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('వార్త పోస్ట్ చేయండి'),
        actions: [
          TextButton(
            onPressed: () async {
              await Reporter.logout();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Logout', style: TextStyle(color: Brand.gold)),
          ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('లాగిన్: ${Reporter.user?.email ?? ''}', style: const TextStyle(color: Brand.muted, fontSize: 12)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _title,
              maxLength: 90,
              decoration: const InputDecoration(labelText: 'శీర్షిక (Headline)', border: OutlineInputBorder()),
              validator: (v) => (v ?? '').trim().isEmpty ? 'శీర్షిక రాయండి' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _body,
              maxLines: 6,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'వార్త (60 పదాల లోపు)',
                border: const OutlineInputBorder(),
                helperText: '$_words / 60 పదాలు',
                helperStyle: TextStyle(color: _words > 60 ? Colors.red : Brand.muted),
              ),
              validator: (v) {
                if ((v ?? '').trim().isEmpty) return 'వార్త రాయండి';
                if (_words > 60) return '60 పదాల లోపు రాయండి';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'విభాగం', border: OutlineInputBorder()),
              items: categories.entries
                  .where((e) => e.key != 'all')
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _district,
              decoration: const InputDecoration(labelText: 'జిల్లా', border: OutlineInputBorder()),
              items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
              onChanged: (v) => setState(() => _district = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'రిపోర్టర్ పేరు', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            if (_photo != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_photo!, height: 180, fit: BoxFit.cover),
              ),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('కెమెరా'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('గ్యాలరీ'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              controller: _video,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                  labelText: 'YouTube వీడియో లింక్ (ఐచ్ఛికం)', border: OutlineInputBorder()),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _notify,
              onChanged: (v) => setState(() => _notify = v),
              title: const Text('అందరికీ నోటిఫికేషన్ పంపు'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Brand.purple,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _busy ? null : _publish,
              child: _busy
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('పబ్లిష్ చేయండి', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
