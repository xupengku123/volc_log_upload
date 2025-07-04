import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:volc_log_upload/log_entity.dart';

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

  @override
  Future<void> initClient({
    required String endpoint,
    required String region,
    required String ak,
    required String sk,
    String? securityToken,
  }) async {
    await methodChannel.invokeMethod('initClient', {
      'endpoint': endpoint,
      'region': region,
      'ak': ak,
      'sk': sk,
      'securityToken': securityToken,
    });
  }

  @override
  Future<String?> sendLog(String topicId,List<LogEntity> logs) async {
    final result = await methodChannel.invokeMethod<String>('sendLog', {
      'topicId': topicId,
      'logs' : logs.map((e) => e.toMap()).toList(),
    });
    return result;
  }
}
