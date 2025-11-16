import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_lock/pin_lock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('pin_lock');
  final recordedCalls = <Map<dynamic, dynamic>>[];

  setUp(() {
    recordedCalls.clear();
    channel.setMockMethodCallHandler((call) async {
      if (call.method == 'setHideAppContent') {
        recordedCalls.add(Map<dynamic, dynamic>.from(call.arguments as Map));
      }
      return null;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('setHideAppContent forwards blockScreenshots preference', () async {
    PinLock.setHideAppContent(
      preference: true,
      iosAssetImage: 'assets/preview.png',
      blockScreenshots: false,
    );

    await Future<void>.delayed(Duration.zero);

    expect(recordedCalls, isNotEmpty);
    final args = recordedCalls.last;
    expect(args['blockScreenshots'], false);
    expect(args['iosAsset'], 'assets/preview.png');
  });

  test('updatePinAuthenticationStatus disables preview hiding when pin off', () async {
    PinLock.setHideAppContent(preference: true, blockScreenshots: true);
    await Future<void>.delayed(Duration.zero);

    PinLock.updatePinAuthenticationStatus(isEnabled: false);
    await Future<void>.delayed(Duration.zero);

    expect(recordedCalls.length, greaterThanOrEqualTo(2));
    final args = recordedCalls.last;
    expect(args['shouldHide'], false);
    expect(args['blockScreenshots'], true);
  });
}
