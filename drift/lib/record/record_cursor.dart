import 'dart:convert';

class RecordCursor {
  final DateTime createdAt;
  final String uuid;
  const RecordCursor(this.createdAt, this.uuid);

  String encode() => base64Url.encode(
      utf8.encode('${createdAt.microsecondsSinceEpoch}|$uuid'));

  static RecordCursor decode(String s) {
    final parts = utf8.decode(base64Url.decode(s)).split('|');
    return RecordCursor(
      DateTime.fromMicrosecondsSinceEpoch(int.parse(parts[0]), isUtc: true),
      parts[1],
    );
  }
}
