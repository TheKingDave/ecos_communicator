import 'package:collection/collection.dart';
import 'listEntry.dart';

class Reply {
  final String type;
  final String extra;
  final int status;
  final String statusStr;
  final List<ListEntry> lines;

  Reply({this.type, this.extra, this.status, this.statusStr, this.lines});

  static final _headerRegex = RegExp(r'^<(?<type>\w+) (?<extra>.*)>$');
  static final _footerRegex =
      RegExp(r'^<END (?<status>\d+) \((?<statusStr>.*)\)>$');

  factory Reply.fromString(String str) {
    final lines = str.trim().split('\n');

    final headerMatch = _headerRegex.firstMatch(lines.first.trim());
    if (headerMatch == null) {
      throw ArgumentError('Header could not be recognised');
    }

    final type = headerMatch.namedGroup('type');
    final extra = headerMatch.namedGroup('extra');

    final footerMatch = _footerRegex.firstMatch(lines.last.trim());
    if (headerMatch == null) {
      throw ArgumentError('Footer could not be recognised');
    }

    final status = int.parse(footerMatch.namedGroup('status'));
    final statusStr = footerMatch.namedGroup('statusStr');

    lines.removeAt(0);
    lines.removeLast();

    return Reply(
        type: type,
        extra: extra,
        status: status,
        statusStr: statusStr,
        lines: lines.map((l) => ListEntry.fromString(l)).toList());
  }

  @override
  String toString() {
    return 'Response{type: $type, extra: $extra, status: $status, statusStr: $statusStr, lines: $lines}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reply &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          extra == other.extra &&
          status == other.status &&
          statusStr == other.statusStr &&
          ListEquality().equals(lines, other.lines);

  @override
  int get hashCode =>
      type.hashCode ^
      extra.hashCode ^
      status.hashCode ^
      statusStr.hashCode ^
      lines.hashCode;
}