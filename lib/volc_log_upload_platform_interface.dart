import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'volc_log_upload_method_channel.dart';

abstract class VolcLogUploadPlatform extends PlatformInterface {
  /// Constructs a VolcLogUploadPlatform.
  VolcLogUploadPlatform() : super(token: _token);

  static final Object _token = Object();

  static VolcLogUploadPlatform _instance = MethodChannelVolcLogUpload();

  /// The default instance of [VolcLogUploadPlatform] to use.
  ///
  /// Defaults to [MethodChannelVolcLogUpload].
  static VolcLogUploadPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VolcLogUploadPlatform] when
  /// they register themselves.
  static set instance(VolcLogUploadPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
