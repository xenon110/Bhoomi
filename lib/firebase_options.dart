import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
/// Configured for studio-6167596920-dbcef
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAQpV-UJLvdjsXH51lqKeo_jGXVYLNRt5s',
    appId: '1:1041595331915:web:1796ea5108cea43a70a4ce',
    messagingSenderId: '1041595331915',
    projectId: 'studio-6167596920-dbcef',
    authDomain: 'studio-6167596920-dbcef.firebaseapp.com',
    storageBucket: 'studio-6167596920-dbcef.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAQpV-UJLvdjsXH51lqKeo_jGXVYLNRt5s',
    appId: '1:1041595331915:android:1796ea5108cea43a70a4ce',
    messagingSenderId: '1041595331915',
    projectId: 'studio-6167596920-dbcef',
    storageBucket: 'studio-6167596920-dbcef.firebasestorage.app',
  );
}

