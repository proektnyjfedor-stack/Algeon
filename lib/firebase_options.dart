// File generated manually from Firebase config files
// flutterfire configure --project=mathpilot-app

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web platform is not configured.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD8IvEme7p5oqOfL5wbPs7efSGCPFjtCug',
    appId: '1:562299772778:android:b68dafb91b70889d894f13',
    messagingSenderId: '562299772778',
    projectId: 'mathpilot-app',
    storageBucket: 'mathpilot-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB-iM99ZY6_Jqzzrxw5CBB_AxS5BhucYmE',
    appId: '1:562299772778:ios:3e3dd7d1f3b8d5cb894f13',
    messagingSenderId: '562299772778',
    projectId: 'mathpilot-app',
    storageBucket: 'mathpilot-app.firebasestorage.app',
    iosBundleId: 'com.example.mathPilot',
    iosClientId: '562299772778-mg9cbg7k9qlljve3rk0931s5tu5mv5t5.apps.googleusercontent.com',
  );
}
