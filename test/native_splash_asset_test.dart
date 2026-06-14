import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shared Flutter splash artwork drives Android and iOS native launch',
      () {
    final sharedSplash = File('assets/branding/sakinah_splash.png');
    final androidSplash = File(
      'android/app/src/main/res/drawable-nodpi/sakinah_native_splash.png',
    );
    final iosSplash = File(
      'ios/Runner/Assets.xcassets/SakinahSplash.imageset/sakinah_splash.png',
    );
    final iosImageSet = File(
      'ios/Runner/Assets.xcassets/SakinahSplash.imageset/Contents.json',
    );
    final iosLaunchScreen = File(
      'ios/Runner/Base.lproj/LaunchScreen.storyboard',
    );
    final iosProject =
        File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    final iosInfoPlist = File('ios/Runner/Info.plist').readAsStringSync();
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(sharedSplash.existsSync(), isTrue);
    expect(androidSplash.existsSync(), isTrue);
    expect(iosSplash.existsSync(), isTrue);
    expect(pubspec, contains('- assets/branding/'));
    expect(_pngSize(sharedSplash), (width: 1080, height: 2400));
    expect(_sha256(androidSplash), _sha256(sharedSplash));
    expect(_sha256(iosSplash), _sha256(sharedSplash));

    final contents = iosImageSet.readAsStringSync();
    expect(contents, contains('sakinah_splash.png'));
    expect(contents, contains('"idiom" : "universal"'));

    final launchScreen = iosLaunchScreen.readAsStringSync();
    expect(launchScreen, contains('image="SakinahSplash"'));
    expect(launchScreen, contains('contentMode="scaleAspectFill"'));
    expect(launchScreen, contains('sakinahSplashImageView'));
    expect(iosProject,
        contains('PRODUCT_BUNDLE_IDENTIFIER = com.sakinahdaily.app;'));
    expect(iosInfoPlist, contains('<string>com.sakinahdaily.app</string>'));
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

String _sha256(File file) {
  return sha256.convert(file.readAsBytesSync()).toString();
}
