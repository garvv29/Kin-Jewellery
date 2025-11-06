import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    }
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return windows;
    }
    if (defaultTargetPlatform == TargetPlatform.linux) {
      return linux;
    }
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return macos;
    }
    // Web support not included for this build
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDVHJhfJKJhfJhfJhfJhf',
    appId: '1:804464780497:android:0c75b207688de741a051f0',
    messagingSenderId: '804464780497',
    projectId: 'jewellery-6d3a4',
    storageBucket: 'jewellery-6d3a4.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDVHJhfJKJhfJhfJhfJhf',
    appId: '1:804464780497:ios:0c75b207688de741a051f0',
    messagingSenderId: '804464780497',
    projectId: 'jewellery-6d3a4',
    storageBucket: 'jewellery-6d3a4.appspot.com',
    iosBundleId: 'com.example.kin',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDVHJhfJKJhfJhfJhfJhf',
    appId: '1:804464780497:windows:0c75b207688de741a051f0',
    messagingSenderId: '804464780497',
    projectId: 'jewellery-6d3a4',
    storageBucket: 'jewellery-6d3a4.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDVHJhfJKJhfJhfJhfJhf',
    appId: '1:804464780497:linux:0c75b207688de741a051f0',
    messagingSenderId: '804464780497',
    projectId: 'jewellery-6d3a4',
    storageBucket: 'jewellery-6d3a4.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDVHJhfJKJhfJhfJhfJhf',
    appId: '1:804464780497:macos:0c75b207688de741a051f0',
    messagingSenderId: '804464780497',
    projectId: 'jewellery-6d3a4',
    storageBucket: 'jewellery-6d3a4.appspot.com',
    iosBundleId: 'com.example.kin',
  );
}
