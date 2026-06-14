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
    final stylesV31 = File('android/app/src/main/res/values-v31/styles.xml')
        .readAsStringSync();
    final nativeSplash = File(
        'android/app/src/main/res/drawable-nodpi/sakinah_native_splash.png');
    final systemSplashMark = File(
        'android/app/src/main/res/drawable/sakinah_splash_system_mark.xml');
    final systemSplashBranding = File(
        'android/app/src/main/res/drawable-nodpi/sakinah_splash_branding.png');
    final oldSystemSplashIcon =
        File('android/app/src/main/res/drawable/sakinah_splash_icon.xml');

    expect(nativeSplash.existsSync(), isTrue);
    expect(systemSplashMark.existsSync(), isTrue);
    expect(systemSplashBranding.existsSync(), isTrue);
    expect(oldSystemSplashIcon.existsSync(), isFalse);
    expect(_pngSize(nativeSplash), (width: 1080, height: 2400));
    expect(_pngSize(systemSplashBranding), (width: 760, height: 420));
    expect(launchBackground, contains('@drawable/sakinah_native_splash'));
    expect(launchBackgroundV21, contains('@drawable/sakinah_native_splash'));
    expect(launchBackground, isNot(contains('@android:color/white')));
    expect(launchBackgroundV21, isNot(contains('?android:colorBackground')));
    expect(stylesV31, contains('android:windowSplashScreenBackground'));
    expect(stylesV31, contains('@drawable/sakinah_splash_system_mark'));
    expect(stylesV31, contains('android:windowSplashScreenBrandingImage'));
    expect(stylesV31, contains('@drawable/sakinah_splash_branding'));
    expect(stylesV31, isNot(contains('@drawable/sakinah_splash_icon')));
    expect(stylesV31, isNot(contains('@mipmap/ic_launcher')));
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
