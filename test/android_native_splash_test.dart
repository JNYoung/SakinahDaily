import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android native launch screen matches the Flutter splash brand', () {
    final launchBackground =
        File('android/app/src/main/res/drawable/launch_background.xml')
            .readAsStringSync();
    final launchBackgroundV21 =
        File('android/app/src/main/res/drawable-v21/launch_background.xml')
            .readAsStringSync();
    final styles =
        File('android/app/src/main/res/values/styles.xml').readAsStringSync();
    final stylesNight = File('android/app/src/main/res/values-night/styles.xml')
        .readAsStringSync();
    final stylesV31 = File('android/app/src/main/res/values-v31/styles.xml')
        .readAsStringSync();
    final nativeSplash = File(
        'android/app/src/main/res/drawable-nodpi/sakinah_native_splash.png');
    final transparentSystemIcon = File(
        'android/app/src/main/res/drawable/sakinah_splash_transparent_icon.xml');
    final oldSystemSplashMark = File(
        'android/app/src/main/res/drawable/sakinah_splash_system_mark.xml');
    final oldSystemSplashBranding = File(
        'android/app/src/main/res/drawable-nodpi/sakinah_splash_branding.png');
    final oldSystemSplashIcon =
        File('android/app/src/main/res/drawable/sakinah_splash_icon.xml');

    expect(nativeSplash.existsSync(), isTrue);
    expect(transparentSystemIcon.existsSync(), isTrue);
    expect(oldSystemSplashMark.existsSync(), isFalse);
    expect(oldSystemSplashBranding.existsSync(), isFalse);
    expect(oldSystemSplashIcon.existsSync(), isFalse);
    expect(_pngSize(nativeSplash), (width: 1080, height: 2400));
    expect(launchBackground, contains('@drawable/sakinah_native_splash'));
    expect(launchBackgroundV21, contains('@drawable/sakinah_native_splash'));
    expect(launchBackground, isNot(contains('@android:color/white')));
    expect(launchBackgroundV21, isNot(contains('?android:colorBackground')));
    expect(stylesV31, contains('android:windowSplashScreenBackground'));
    expect(stylesV31, contains('@drawable/sakinah_splash_transparent_icon'));
    expect(
        stylesV31, isNot(contains('android:windowSplashScreenBrandingImage')));
    expect(stylesV31, isNot(contains('@drawable/sakinah_splash_system_mark')));
    expect(stylesV31, isNot(contains('@drawable/sakinah_splash_branding')));
    expect(stylesV31, isNot(contains('@drawable/sakinah_splash_icon')));
    expect(stylesV31, isNot(contains('@mipmap/ic_launcher')));
    expect(
      styles,
      contains(
        '<item name="android:windowBackground">@drawable/launch_background</item>',
      ),
    );
    expect(
      stylesNight,
      contains(
        '<item name="android:windowBackground">@drawable/launch_background</item>',
      ),
    );
    expect(
      stylesV31,
      contains(
        '<item name="android:windowBackground">@drawable/launch_background</item>',
      ),
    );
  });
}

({int width, int height}) _pngSize(File file) {
  final bytes = file.readAsBytesSync();
  final data = ByteData.sublistView(Uint8List.fromList(bytes));
  return (
    width: data.getUint32(16),
    height: data.getUint32(20),
  );
}
