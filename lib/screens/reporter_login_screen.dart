import 'package:flutter/material.dart';
import '../data/reporter.dart';
import '../theme.dart';
import 'post_screen.dart';

/// Hidden screen: opened only by long-pressing the TeluguTV logo.
class ReporterLoginScreen extends StatefulWidget {
  const ReporterLoginScreen({super.key});
  @override
  State<ReporterLoginScreen> createState() => _ReporterLoginScreenState();
}

class _ReporterLoginScreenState extends State<ReporterLoginScreen> {
  final _email = TextEditingController();
  final _pw = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await Reporter.login(_email.text, _pw.text);
    if (!mounted) return;
    if (err == null) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PostScreen()));
    } else {
      setState(() {
        _busy = false;
        _error = err;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('రిపోర్టర్ లాగిన్')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Image.asset('assets/images/logo.png', height: 90),
          const SizedBox(height: 24),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pw,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            onSubmitted: (_) => _login(),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Brand.purple,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _busy ? null : _login,
            child: _busy
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('లాగిన్', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 16),
          const Text('TeluguTV రిపోర్టర్లకు మాత్రమే. ఖాతా కోసం ఆఫీస్‌ను సంప్రదించండి.',
              textAlign: TextAlign.center, style: TextStyle(color: Brand.muted, fontSize: 12)),
        ],
      ),
    );
  }
}
