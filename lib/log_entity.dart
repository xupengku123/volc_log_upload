
class LogEntity {
  final DateTime createTime;
  final String content;
  final String? source;
  final String? path;
  final String? accountId;
  final String? level;
  final String? type;

  LogEntity({
    required this.createTime,
    required this.content,
    this.source,
    this.path,
    this.accountId,
    this.level,
    this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'createTime': createTime.millisecondsSinceEpoch,
      'content': content,
      'source': source,
      'path': path,
      'accountId': accountId,
      'level': level,
      'type': type,
    };
  }
}