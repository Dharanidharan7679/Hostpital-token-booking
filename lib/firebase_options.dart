import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyAM8lfbIWW8Px1CXdupCpxw-dRk9iRF5Rw',
      appId: '1:921261536510:web:1234567890abcdef', // Placeholder web app ID, using Android keys below
      messagingSenderId: '921261536510',
      projectId: 'digitalqueue-1234',
      storageBucket: 'digitalqueue-1234.firebasestorage.app',
    );
  }
}
