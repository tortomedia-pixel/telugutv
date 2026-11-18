// ============================================================
//  TeluguTV app settings — edit this file only.
// ============================================================

class AppConfig {
  static const appName = 'TeluguTV';

  // Your YouTube channel (Telugu TV LIVE)
  static const youtubeChannelId = 'UCOV3tcpsK9mBgHalXMyNjnQ';
  static const youtubeHandleUrl = 'https://www.youtube.com/@telugutv24x7';
  static const youtubeLiveUrl = 'https://www.youtube.com/@telugutv24x7/live';

  // Shown at the end of every shared story. Put your Play Store link here
  // once the app is published.
  static const shareFooter = '— TeluguTV News App\nhttps://www.youtube.com/@telugutv24x7';

  // ---- Firebase (from Firebase console > Project settings > Your apps > Android) ----
  // Leave apiKey empty to run the app in DEMO mode with sample stories.
  static const firebaseApiKey = 'AIzaSyDvYKe6Vfk_3JurGm7AY8sAQy4te3JYEbg';
  static const firebaseAppId = '1:354338268019:android:684253eddae202eeeb5b06';
  static const firebaseMessagingSenderId = '354338268019';
  static const firebaseProjectId = 'telugutv';
  static const firebaseStorageBucket = 'telugutv.firebasestorage.app';

  static bool get firebaseEnabled => firebaseApiKey.isNotEmpty;
}
