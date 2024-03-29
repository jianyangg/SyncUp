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
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyCdp3sgdnDjmn_eVTgJxO7Oqwk-i-8o6Bs',
    appId: '1:894771916019:web:85d844353a5ca9e337db86',
    messagingSenderId: '894771916019',
    projectId: 'syncup-278db',
    authDomain: 'syncup-278db.firebaseapp.com',
    storageBucket: 'syncup-278db.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBaL8jbzUkcvR4jBv_CSKTvUHMiQKKxGqI',
    appId: '1:894771916019:android:9817df468e56b08837db86',
    messagingSenderId: '894771916019',
    projectId: 'syncup-278db',
    storageBucket: 'syncup-278db.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDvPbK1w_qK85Pq4yLxe79SfdIM1NaQTHk',
    appId: '1:894771916019:ios:86bd74f8e9a4a68837db86',
    messagingSenderId: '894771916019',
    projectId: 'syncup-278db',
    storageBucket: 'syncup-278db.appspot.com',
    androidClientId: '894771916019-lqrmngjp9sriih5fiped1ffg9d4tp8o7.apps.googleusercontent.com',
    iosClientId: '894771916019-hvmdua4jkl6aj73qmtibt8i03lgkfgma.apps.googleusercontent.com',
    iosBundleId: 'com.jianyang.syncUp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDvPbK1w_qK85Pq4yLxe79SfdIM1NaQTHk',
    appId: '1:894771916019:ios:fb150c3b0e3f653637db86',
    messagingSenderId: '894771916019',
    projectId: 'syncup-278db',
    storageBucket: 'syncup-278db.appspot.com',
    androidClientId: '894771916019-lqrmngjp9sriih5fiped1ffg9d4tp8o7.apps.googleusercontent.com',
    iosClientId: '894771916019-beaamr5kki43iv0v3m4s1o4cadunlf60.apps.googleusercontent.com',
    iosBundleId: 'com.example.syncUp.RunnerTests',
  );
}
