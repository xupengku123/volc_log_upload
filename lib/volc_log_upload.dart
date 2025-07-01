
import 'volc_log_upload_platform_interface.dart';

class VolcLogUpload {
  Future<String?> getPlatformVersion() {
    return VolcLogUploadPlatform.instance.getPlatformVersion();
  }
}
