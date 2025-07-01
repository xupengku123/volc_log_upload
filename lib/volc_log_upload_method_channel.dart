import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'volc_log_upload_platform_interface.dart';

/// An implementation of [VolcLogUploadPlatform] that uses method channels.
class MethodChannelVolcLogUpload extends VolcLogUploadPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('volc_log_upload');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
