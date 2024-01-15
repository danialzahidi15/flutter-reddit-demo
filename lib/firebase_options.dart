// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      // case TargetPlatform.macOS:
      //   return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB0pzxI0UzHOG2UbCbIz6r4N4sAgvTzxoM',
    appId: '1:48633089480:web:2a2882b93336e6a17844fd',
    messagingSenderId: '48633089480',
    projectId: 'reddit-clone-b6eb1',
    authDomain: 'reddit-clone-b6eb1.firebaseapp.com',
    storageBucket: 'reddit-clone-b6eb1.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA6PRIA5Kt4UVg6oP6rpqo7IZmaucKEZJ8',
    appId: '1:48633089480:android:c1ac6a57656cf4447844fd',
    messagingSenderId: '48633089480',
    projectId: 'reddit-clone-b6eb1',
    storageBucket: 'reddit-clone-b6eb1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB7qhWrJI7-oxtca3JKso49rK0Kzc82PiQ',
    appId: '1:48633089480:ios:102a91dda009fb9c7844fd',
    messagingSenderId: '48633089480',
    projectId: 'reddit-clone-b6eb1',
    storageBucket: 'reddit-clone-b6eb1.appspot.com',
    iosBundleId: 'com.example.flutterDanthocodeReddit',
  );
}
