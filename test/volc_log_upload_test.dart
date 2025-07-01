import 'package:flutter_test/flutter_test.dart';
import 'package:volc_log_upload/volc_log_upload.dart';
import 'package:volc_log_upload/volc_log_upload_platform_interface.dart';
import 'package:volc_log_upload/volc_log_upload_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockVolcLogUploadPlatform
    with MockPlatformInterfaceMixin
    implements VolcLogUploadPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final VolcLogUploadPlatform initialPlatform = VolcLogUploadPlatform.instance;

  test('$MethodChannelVolcLogUpload is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelVolcLogUpload>());
  });

  test('getPlatformVersion', () async {
    VolcLogUpload volcLogUploadPlugin = VolcLogUpload();
    MockVolcLogUploadPlatform fakePlatform = MockVolcLogUploadPlatform();
    VolcLogUploadPlatform.instance = fakePlatform;

    expect(await volcLogUploadPlugin.getPlatformVersion(), '42');
  });
}
