enum LogEntityType {
  click,
  network,
}

class LogEntity {
  final DateTime createTime;
  final String content;
  final String level;
  final String version;

  // 平台
  final String platform;

  // 机型：如小米redmi note 9
  final String? model;

  final String? path;
  final String? accountId;
  final LogEntityType? type;

  LogEntity({
    required this.createTime,
    required this.content,
    required this.level,
    required this.version,
    required this.platform,
    this.model,
    this.path,
    this.accountId,
    this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'createTime': createTime.millisecondsSinceEpoch,
      'content': content,
      'level': level,
      'version': version,
      'platform': platform,
      'model': model,
      'path': path,
      'accountId': accountId,
      'type': type?.name,
    };
  }
}
