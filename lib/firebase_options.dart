import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Platform saat ini tidak didukung oleh FirebaseOptions.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA-leGdYH7c4fR1i7fqU0ShxUBtCMahcdY',
    appId: '1:53677295897:android:bbd5a985b48449bb4b1d88',
    messagingSenderId: '53677295897',
    projectId: 'smart-expense-tracker-c572e',
    storageBucket: 'smart-expense-tracker-c572e.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC7c73rSUyJSbE2wvHy6Ye3i7KN0x9KFXI',
    appId: '1:53677295897:web:09209c637797d02c4b1d88',
    messagingSenderId: '53677295897',
    projectId: 'smart-expense-tracker-c572e',
    authDomain: 'smart-expense-tracker-c572e.firebaseapp.com',
    storageBucket: 'smart-expense-tracker-c572e.firebasestorage.app',
  );
}
