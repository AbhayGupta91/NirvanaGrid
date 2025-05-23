// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyDo5z_etbVS2NqT0RxC3v1hSwQSGCetw6g',
    appId: '1:44830343475:web:6e13fe9010fcb5929bfe46',
    messagingSenderId: '44830343475',
    projectId: 'projectx-c1142',
    authDomain: 'projectx-c1142.firebaseapp.com',
    storageBucket: 'projectx-c1142.firebasestorage.app',
    measurementId: 'G-T0YLY1RHY3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdXX2ujohgvqUWFm_KrPrIMg9k25HCCeE',
    appId: '1:44830343475:android:1099159bf883421c9bfe46',
    messagingSenderId: '44830343475',
    projectId: 'projectx-c1142',
    storageBucket: 'projectx-c1142.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCCho8OJsTfkuXW3nKEzeJYGFRJwiatEBI',
    appId: '1:44830343475:ios:ab9c77bd378a00f69bfe46',
    messagingSenderId: '44830343475',
    projectId: 'projectx-c1142',
    storageBucket: 'projectx-c1142.firebasestorage.app',
    iosBundleId: 'com.example.myapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCCho8OJsTfkuXW3nKEzeJYGFRJwiatEBI',
    appId: '1:44830343475:ios:ab9c77bd378a00f69bfe46',
    messagingSenderId: '44830343475',
    projectId: 'projectx-c1142',
    storageBucket: 'projectx-c1142.firebasestorage.app',
    iosBundleId: 'com.example.myapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDo5z_etbVS2NqT0RxC3v1hSwQSGCetw6g',
    appId: '1:44830343475:web:9c65592c5425958d9bfe46',
    messagingSenderId: '44830343475',
    projectId: 'projectx-c1142',
    authDomain: 'projectx-c1142.firebaseapp.com',
    storageBucket: 'projectx-c1142.firebasestorage.app',
    measurementId: 'G-E3880VDB60',
  );
}