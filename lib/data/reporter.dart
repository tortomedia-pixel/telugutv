import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../config.dart';
import 'news.dart';

/// Reporter (admin) session. Only accounts listed in the Firestore
/// "admins" collection count as reporters; everyone else is a normal reader.
/// The same check is enforced on the server by firestore.rules.
class Reporter {
  static final isReporter = ValueNotifier<bool>(false);

  static User? get user =>
      AppConfig.firebaseEnabled ? FirebaseAuth.instance.currentUser : null;

  /// Called at app start: keeps a reporter logged in between app launches.
  static Future<void> restore() async {
    if (user == null) return;
    isReporter.value = await _isAdmin(user!.uid);
  }

  static Future<bool> _isAdmin(String uid) async {
    try {
      final d = await FirebaseFirestore.instance.collection('admins').doc(uid).get();
      return d.exists;
    } catch (_) {
      return false;
    }
  }

  /// Returns null on success, or a Telugu error message.
  static Future<String?> login(String email, String password) async {
    if (!AppConfig.firebaseEnabled) {
      return 'Firebase ఇంకా కనెక్ట్ కాలేదు (config.dart).';
    }
    try {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      final ok = await _isAdmin(cred.user!.uid);
      if (!ok) {
        await FirebaseAuth.instance.signOut();
        return 'ఈ ఖాతాకు వార్తలు పోస్ట్ చేసే అనుమతి లేదు.';
      }
      isReporter.value = true;
      return null;
    } on FirebaseAuthException catch (_) {
      return 'ఈమెయిల్ లేదా పాస్‌వర్డ్ తప్పు.';
    } catch (e) {
      return 'లాగిన్ విఫలమైంది: $e';
    }
  }

  static Future<void> logout() async {
    if (AppConfig.firebaseEnabled) await FirebaseAuth.instance.signOut();
    isReporter.value = false;
  }

  static Future<void> publish({
    required String title,
    required String body,
    required String category,
    required String district,
    required String reporterName,
    required String videoUrl,
    required bool notify,
    File? photo,
  }) async {
    var imageUrl = '';
    if (photo != null) {
      final ref = FirebaseStorage.instance
          .ref('news/${DateTime.now().millisecondsSinceEpoch}_${user!.uid}.jpg');
      await ref.putFile(photo, SettableMetadata(contentType: 'image/jpeg'));
      imageUrl = await ref.getDownloadURL();
    }
    await FirebaseFirestore.instance.collection('news').add({
      'title': title,
      'body': body,
      'category': category,
      'district': district,
      'districtIndex': districts.indexOf(district),
      'reporter': reporterName.isEmpty ? 'TeluguTV Reporter' : reporterName,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'notify': notify,
      'published': true,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': user?.email ?? '',
    });
  }
}
