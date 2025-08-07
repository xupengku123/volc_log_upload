import Flutter
import Network
import UIKit
import VeTLSiOSSDK

public class VolcLogUploadPlugin: NSObject, FlutterPlugin {
    private var tlsLogClient: TLSClient?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "volc_log_upload", binaryMessenger: registrar.messenger())
        let instance = VolcLogUploadPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initClient":
            guard
                let args = call.arguments as? [String: Any],
                let endpoint = args["endpoint"] as? String,
                let region = args["region"] as? String,
                let ak = args["ak"] as? String,
                let sk = args["sk"] as? String
            else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing initClient arguments", details: nil))
                return
            }

            initClient(endpoint: endpoint, region: region, ak: ak, sk: sk, result: result)

        case "sendLog":
            guard
                let args = call.arguments as? [String: Any],
                let topicId = args["topicId"] as? String,
                let logs = args["logs"] as? [[String: Any]]
            else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing sendLog args", details: nil))
                return
            }

            sendLogV2(topicId: topicId, logs: logs, result: result)

        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initClient(endpoint: String, region: String, ak: String, sk: String, result: FlutterResult) {
        if tlsLogClient != nil {
            result(nil)
            return
        }

        let config = TLSClientConfig()
        config.endpoint = endpoint
        config.region = region
        config.accessKeyId = ak
        config.accessKeySecret = sk

        tlsLogClient = TLSClient(config: config)
        result(nil)
    }

    private func sendLogV2(topicId: String, logs: [[String: Any]], result: @escaping FlutterResult) {
        guard let client = tlsLogClient else {
            result(FlutterError(code: "NO_CLIENT", message: "TLSLogClient is not initialized", details: nil))
            return
        }

        isNetworkAvailable { satisfied in
            if !satisfied {
                result(FlutterError(code: "-1", message: "当前网络不可用", details: nil))
                return
            }

            let request = PutLogsV2Request()
            request.topicId = topicId
            var tempLogs = [PutLogsV2LogItem]()

            do {
                for log in logs {
                    let timeStamp: NSNumber
                    if let createTime = log["createTime"] as? Int {
                        timeStamp = NSNumber(value: createTime)
                    } else {
                        timeStamp = NSNumber(value: Int64(Date().timeIntervalSince1970 * 1000))
                    }

                    let logItem = PutLogsV2LogItem(keyValueAndTime: log, timeStamp: timeStamp)

                    if logItem != nil {
                        logItem!.time = timeStamp
                        tempLogs.append(logItem!)
                    }
                }
                request.logs = tempLogs

                // 不阻塞当前线程
                let task = client.putLogsV2Async(request)

                task?.continueWith(block: { t in
                    if let error = t.error {
                        result(FlutterError(code: "-1", message: "Encountered error: \(error)", details: nil))
                        return
                    } else if let response = t.result as? GeneralHttpResponse {
                        var responseDict: [String: Any] = [:]

                        if response.requestId != nil {
                            responseDict["requestId"] = response.requestId
                        }

                        if response.httpStatusCode.intValue != nil {
                            responseDict["httpStatusCode"] = response.httpStatusCode.intValue
                        }

                        let responseBody = String(data: response.responseBody ?? Data(), encoding: .utf8) ?? ""
                        responseDict["responseBody"] = responseBody

                        if let jsonData = try? JSONSerialization.data(withJSONObject: responseDict, options: []),
                           let jsonString = String(data: jsonData, encoding: .utf8) {
                            result(jsonString)
                        } else {
                            result(FlutterError(code: "SERIALIZATION_ERROR", message: "Failed to serialize response", details: nil))
                        }
                        return
                    }

                    result("未知问题")
                    return
                })

            } catch {
                result(FlutterError(code: "UPLOAD_EXCEPTION", message: "日志上传失败", details: error.localizedDescription))
            }
        }
    }

    func isNetworkAvailable(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")

        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                completion(true)
            } else {
                completion(false)
            }
            monitor.cancel() // 用完就取消，避免内存泄漏
        }

        monitor.start(queue: queue)
    }
}
