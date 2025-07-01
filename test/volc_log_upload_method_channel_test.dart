import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volc_log_upload/volc_log_upload_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelVolcLogUpload platform = MethodChannelVolcLogUpload();
  const MethodChannel channel = MethodChannel('volc_log_upload');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
