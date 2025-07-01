package com.xpk.volc_log_upload;

import androidx.annotation.NonNull;

import com.volcengine.model.tls.ClientBuilder;
import com.volcengine.model.tls.ClientConfig;
import com.volcengine.model.tls.Const;
import com.volcengine.model.tls.exception.LogException;
import com.volcengine.model.tls.pb.PutLogRequest;
import com.volcengine.model.tls.request.PutLogsRequest;
import com.volcengine.model.tls.response.PutLogsResponse;
import com.volcengine.service.tls.TLSLogClient;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** VolcLogUploadPlugin */
public class VolcLogUploadPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private TLSLogClient tlsLogClient;
  private int logCount = 0;
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "volc_log_upload");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "initClient":
        String endpoint = call.argument("endpoint");
        String region = call.argument("region");
        String ak = call.argument("ak");
        String sk = call.argument("sk");
        String token = call.argument("securityToken");
        initClient(endpoint, region, ak, sk, token);
        result.success(null);
        break;
      case "sendLog":
        String topicId = call.argument("topicId");
        sendLog(topicId, result);
        break;
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      default:
        result.notImplemented();
    }
  }

  private void initClient(String endpoint, String region, String ak, String sk, String token) {
    ClientConfig config = new ClientConfig(endpoint, region, ak, sk, token);
    try {
      tlsLogClient = ClientBuilder.newClient(config);
    } catch (LogException e) {
      e.printStackTrace();
    }
  }

  private void sendLog(String topicId, MethodChannel.Result result) {
    if (tlsLogClient == null) {
      result.error("NO_CLIENT", "TLSLogClient is not initialized", null);
      return;
    }
    try {
      PutLogsRequest req = oneLogsRequest(topicId);
      PutLogsResponse resp = tlsLogClient.putLogs(req);
      logCount++;
      result.success("success:" + logCount);
    } catch (LogException e) {
      e.printStackTrace();
      result.error("LOG_ERROR", e.getMessage(), null);
    }
  }

  private PutLogsRequest oneLogsRequest(String topicId) {
    long time = System.currentTimeMillis();

    PutLogRequest.LogContent content = PutLogRequest.LogContent.newBuilder()
            .setKey("test-key-" + time)
            .setValue("test-value")
            .build();

    PutLogRequest.Log log = PutLogRequest.Log.newBuilder()
            .setTime(time)
            .addContents(content)
            .build();

    PutLogRequest.LogGroup logGroup = PutLogRequest.LogGroup.newBuilder()
            .setSource("test-source-" + time)
            .setFileName("test5.txt")
            .addLogs(log)
            .build();

    PutLogRequest.LogGroupList groupList = PutLogRequest.LogGroupList.newBuilder()
            .addLogGroups(logGroup)
            .build();

    PutLogsRequest req = new PutLogsRequest(groupList, topicId);
    req.setCompressType(Const.LZ4);
    return req;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
