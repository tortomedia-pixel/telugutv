import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'config.dart';
import 'data/news.dart';
import 'data/repository.dart';
import 'theme.dart';
import 'screens/home_shell.dart';

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage message) async {
  // Android shows the notification itself; nothing else to do here.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalPrefs.init();

  if (AppConfig.firebaseEnabled) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: AppConfig.firebaseApiKey,
        appId: AppConfig.firebaseAppId,
        messagingSenderId: AppConfig.firebaseMessagingSenderId,
        projectId: AppConfig.firebaseProjectId,
        storageBucket: AppConfig.firebaseStorageBucket,
      ),
    );
    FirebaseMessaging.onBackgroundMessage(_bgHandler);
    try {
      await FirebaseMessaging.instance.requestPermission();
      await FirebaseMessaging.instance.subscribeToTopic('news');
      if (LocalPrefs.district.isNotEmpty) {
        await FirebaseMessaging.instance
            .subscribeToTopic(districtTopic(LocalPrefs.district));
      }
    } catch (_) {
      // Notifications are optional; the app still works without them.
    }
  }

  runApp(const TeluguTvApp());
}

class TeluguTvApp extends StatelessWidget {
  const TeluguTvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeShell(),
    );
  }
}
