import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:volc_log_upload/log_entity.dart';
import 'package:volc_log_upload/volc_log_upload.dart';
import 'package:volc_log_upload_example/constans.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _volcLogUploadPlugin = VolcLogUpload();

  List<LogEntity> logs = [
    LogEntity(
        createTime: DateTime.now(),
        content: '11111',
        platform: 'android',
        path: 'homepageRouter',
        level: 'error',
        type: LogEntityType.click,
        version: 'v1.42.0'),
    LogEntity(
        createTime: DateTime.now(),
        content: '22222',
        platform: 'android',
        path: 'homepageRouter',
        level: 'info',
        type: LogEntityType.click,
        version: 'v1.42.0'),
    LogEntity(
        createTime: DateTime.now(),
        content: '33333',
        platform: 'android',
        path: 'homepageRouter',
        level: 'waring',
        type: LogEntityType.click,
        version: 'v1.42.0'),
    LogEntity(
        createTime: DateTime.now(),
        content: '44444',
        platform: 'android',
        path: 'homepageRouter',
        level: 'waring',
        type: LogEntityType.network,
        version: 'v1.42.0'),
    LogEntity(
        createTime: DateTime.now(),
        content: '55555',
        platform: 'ios',
        path: 'message',
        level: 'waring',
        type: LogEntityType.network,
        version: 'v1.42.0'),
  ];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _volcLogUploadPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    uploadLog() async {
      await _volcLogUploadPlugin.initClient(
          endpoint: ConstantValue.endpoint, region: ConstantValue.region, ak: ConstantValue.ak, sk: ConstantValue.sk);
      _volcLogUploadPlugin.sendLog(ConstantValue.topicId, logs);
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: TextButton(
              onPressed: () {
                uploadLog();
              },
              child: Text('上传日志')),
        ),
      ),
    );
  }
}
