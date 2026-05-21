import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android native launch screen uses Sakinah artwork', () {
    final launchBackground =
        File('android/app/src/main/res/drawable/launch_background.xml')
            .readAsStringSync();
    final launchBackgroundV21 =
        File('android/app/src/main/res/drawable-v21/launch_background.xml')
            .readAsStringSync();
    final stylesV31 = File('android/app/src/main/res/values-v31/styles.xml')
        .readAsStringSync();
    final nativeSplash = File(
        'android/app/src/main/res/drawable-nodpi/sakinah_native_splash.png');
    final systemSplashIcon =
        File('android/app/src/main/res/drawable/sakinah_splash_icon.xml');

    expect(nativeSplash.existsSync(), isTrue);
    expect(systemSplashIcon.existsSync(), isTrue);
    expect(launchBackground, contains('@drawable/sakinah_native_splash'));
    expect(launchBackgroundV21, contains('@drawable/sakinah_native_splash'));
    expect(launchBackground, isNot(contains('@android:color/white')));
    expect(launchBackgroundV21, isNot(contains('?android:colorBackground')));
    expect(stylesV31, contains('android:windowSplashScreenBackground'));
    expect(stylesV31, contains('@drawable/sakinah_splash_icon'));
    expect(stylesV31, isNot(contains('@mipmap/ic_launcher')));
  });
}
