
import 'volc_log_upload_platform_interface.dart';

class VolcLogUpload {
  Future<String?> getPlatformVersion() {
    return VolcLogUploadPlatform.instance.getPlatformVersion();
  }

  Future<void> initClient({
    required String endpoint,
    required String region,
    required String ak,
    required String sk,
    String? securityToken,
  }) {
    return VolcLogUploadPlatform.instance.initClient(
      endpoint: endpoint,
      region: region,
      ak: ak,
      sk: sk,
      securityToken: securityToken,
    );
  }

  Future<String?> sendLog(String topicId) {
    return VolcLogUploadPlatform.instance.sendLog(topicId);
  }
}
