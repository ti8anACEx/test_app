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
    apiKey: 'AIzaSyB2elyh-adPfZAIr09Dp0t_FVuJKQlTWGw',
    appId: '1:123510033549:web:0821ef93c61a1b7b5526c4',
    messagingSenderId: '123510033549',
    projectId: 'innodify-db',
    authDomain: 'innodify-db.firebaseapp.com',
    storageBucket: 'innodify-db.appspot.com',
    measurementId: 'G-MN7TF87K62',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBoPfxZMbF1nWJDeh6-5H3baJ26-zf8-HY',
    appId: '1:123510033549:android:c4e4e9fcdb1496b85526c4',
    messagingSenderId: '123510033549',
    projectId: 'innodify-db',
    storageBucket: 'innodify-db.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA2GqridjZ-497LjwbOjL8thlr-ic1RjbE',
    appId: '1:123510033549:ios:2ed4b112f4cd9e375526c4',
    messagingSenderId: '123510033549',
    projectId: 'innodify-db',
    storageBucket: 'innodify-db.appspot.com',
    iosBundleId: 'com.innodify.Sauda2Sale',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA2GqridjZ-497LjwbOjL8thlr-ic1RjbE',
    appId: '1:123510033549:ios:504c33b5d256018e5526c4',
    messagingSenderId: '123510033549',
    projectId: 'innodify-db',
    storageBucket: 'innodify-db.appspot.com',
    iosBundleId: 'com.example.testApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB2elyh-adPfZAIr09Dp0t_FVuJKQlTWGw',
    appId: '1:123510033549:web:eccd4141519748365526c4',
    messagingSenderId: '123510033549',
    projectId: 'innodify-db',
    authDomain: 'innodify-db.firebaseapp.com',
    storageBucket: 'innodify-db.appspot.com',
    measurementId: 'G-QZ0JJ11YPC',
  );

}