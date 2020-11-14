import 'package:collection/collection.dart';

import 'listEntry.dart';

/// Response sent from the ECoS
///
/// Syntax:
/// ```
/// <$type $extra>
/// [$entries]+
/// <END $state ($statusMsg)>
/// ```
///
/// Example:
/// ```
/// <REPLY get(20000, state, name1)>
/// 20000 state[1]
/// 20000 name1["Weiche"]
/// <END 0 (OK)>
/// ```
class Response {
  /// The type of the reply (REPLY, EVENT)
  final String type;

  /// The command or id of the Reply
  final String extra;

  /// The status number (errno)
  final int status;

  /// The status message (errmsg)
  final String statusMsg;

  /// The list entries ([ListEntry]*)
  final List<ListEntry> entries;

  /// Creates a Response with the supplied parameters
  Response({this.type, this.extra, this.status, this.statusMsg, this.entries});

  static final _headerRegex = RegExp(r'^<(?<type>\w+) (?<extra>.*)>$');
  static final _footerRegex =
      RegExp(r'^<END (?<status>\d+) \((?<statusStr>.*)\)>$');

  /// Parses a [Response] from string
  factory Response.fromString(String str) {
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

    return Response(
        type: type,
        extra: extra,
        status: status,
        statusMsg: statusStr,
        entries: lines.map((l) => ListEntry.fromString(l)).toList());
  }

  @override
  String toString() {
    return 'Response{type: $type, extra: $extra, status: $status, statusMsg: $statusMsg, entries: $entries}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Response &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          extra == other.extra &&
          status == other.status &&
          statusMsg == other.statusMsg &&
          ListEquality().equals(entries, other.entries);

  @override
  int get hashCode =>
      type.hashCode ^
      extra.hashCode ^
      status.hashCode ^
      statusMsg.hashCode ^
      ListEquality().hash(entries);
}
