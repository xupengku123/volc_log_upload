package com.xpk.volc_log_upload;

import static com.volcengine.model.tls.Const.LZ4;

import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;

import com.volcengine.model.tls.ClientBuilder;
import com.volcengine.model.tls.ClientConfig;
import com.volcengine.model.tls.LogItem;
import com.volcengine.model.tls.exception.LogException;
import com.volcengine.model.tls.pb.PutLogRequest;
import com.volcengine.model.tls.request.PutLogsRequest;
import com.volcengine.model.tls.request.PutLogsRequestV2;
import com.volcengine.model.tls.response.PutLogsResponse;
import com.volcengine.service.tls.TLSLogClient;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

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
        initClient(endpoint, region, ak, sk, token,result);

        break;
      case "sendLog":
        String topicId = call.argument("topicId");
        // 获取 logs
        List<Map<String, Object>> logs = call.argument("logs");

        sendLogV2(topicId, logs,result);
        break;
      case "getPlatformVersion":
        result.success("Android " + Build.VERSION.RELEASE);
        break;
      default:
        result.notImplemented();
    }
  }

  private void initClient(String endpoint, String region, String ak, String sk, String token, Result result) {
    if(tlsLogClient != null){
      result.success(null);
      return;
    }
    ClientConfig config = new ClientConfig(endpoint, region, ak, sk);
    try {
      tlsLogClient = ClientBuilder.newClient(config);
      result.success(null);
    } catch (LogException e) {
      result.error(e.getErrorCode(),e.getErrorMessage(),e.getMessage());
    }
  }
  //这个方法不用 用的下面V2
  private void sendLog(String topicId, Result result) {
    if (tlsLogClient == null) {
      result.error("NO_CLIENT", "TLSLogClient is not initialized", null);
      return;
    }
      new Thread(() -> {
        PutLogsRequest req = oneLogsRequest(topicId);
          PutLogsResponse resp = null;
          try {
              resp = tlsLogClient.putLogs(req);
          } catch (LogException e) {
            result.error("UPLOAD_EXCEPTION", "火山引擎上传日志异常", null);
          }
          Log.i("put logs success","response:" +resp);
        logCount++;
        result.success("success:" + logCount);
      }).start();
  }

  private void sendLogV2(String topicId, List<Map<String, Object>> logs,Result result) {
    if (tlsLogClient == null) {
      result.error("NO_CLIENT", "TLSLogClient is not initialized", null);
      return;
    }
    new Thread(() -> {
      // 写入日志
      List<LogItem> resultLogs = new ArrayList<>();

      if(logs!= null && !logs.isEmpty()){
        for (Map<String, Object> log : logs) {
          Long createTimeMillis = (Long) log.get("createTime");
          String content = (String) log.get("content");
          String source = (String) log.get("source");
          String path = (String) log.get("path");
          String accountId = (String) log.get("accountId");
          String level = (String) log.get("level");
          String type = (String) log.get("type");
          if(createTimeMillis==null){
            createTimeMillis = System.currentTimeMillis();
          }
          LogItem item = new LogItem(createTimeMillis);
          safeAddContent(item, "content", content);
          safeAddContent(item, "source", source);
          safeAddContent(item, "path", path);
          safeAddContent(item, "accountId", accountId);
          safeAddContent(item, "level", level);
          safeAddContent(item, "type", type);

          Log.d("Plugin", "LogEntity: " + createTimeMillis + ", content=" + content + ", source=" + source +
                  ", path=" + path + ", accountId=" + accountId + ", level=" + level + ", type=" + type);
          resultLogs.add(item);
        }
      }
      if(resultLogs.isEmpty()){
        return;
      }
        try {
            PutLogsRequestV2 putLogsRequestV2 = new PutLogsRequestV2(resultLogs, topicId, null, LZ4);
            PutLogsResponse putLogsResponse = tlsLogClient.putLogsV2(putLogsRequestV2);
          Log.i("put logs success","response:" +putLogsResponse);
          result.success("success:");
        } catch (LogException e) {
          result.error("UPLOAD_EXCEPTION", "火山引擎上传日志异常", null);
        }
    }).start();
  }

  private void safeAddContent(LogItem item, String key, String value) {
    if (value != null) {
      item.addContent(key, value);
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
    req.setCompressType(LZ4);
    return req;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
