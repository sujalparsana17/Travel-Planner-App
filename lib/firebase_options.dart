import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDDnCsVJ4EbgQDh2_ZNpwCPUXKtqiaBzSU',
    appId: '1:219987698568:web:1db2d9e01996f586bc103d',
    messagingSenderId: '219987698568',
    projectId: 'travel-planner-app-cee58',
    authDomain: 'travel-planner-app-cee58.firebaseapp.com',
    storageBucket: 'travel-planner-app-cee58.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDDnCsVJ4EbgQDh2_ZNpwCPUXKtqiaBzSU',
    appId: '1:219987698568:android:1db2d9e01996f586bc103d',
    messagingSenderId: '219987698568',
    projectId: 'travel-planner-app-cee58',
    storageBucket: 'travel-planner-app-cee58.firebasestorage.app',
  );
}
