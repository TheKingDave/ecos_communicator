import 'package:collection/collection.dart';
import 'listEntry.dart';
import 'request.dart';
import 'response.dart';

/// Reply sent from the ECoS
///
/// Syntax:
/// ```
/// <REPLY $command>
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
class Reply {
  /// The command of the Reply
  final Request command;

  /// The status number (errno)
  final int status;

  /// The status message (errmsg)
  final String statusMsg;

  /// The list entries ([ListEntry]*)
  final List<ListEntry> entries;

  /// Returns the first [ListEntry] from [entries]
  ListEntry get entry {
    return entries.first;
  }

  /// Creates a Reply with the supplied parameters
  Reply({this.command, this.status, this.statusMsg, this.entries});

  /// Creates a [Reply] from a [Response]
  factory Reply.fromResponse(Response response) {
    assert(response.type == 'REPLY');
    return Reply(
        command: Request.fromString(response.extra),
        status: response.status,
        statusMsg: response.statusMsg,
        entries: response.entries);
  }

  @override
  String toString() {
    return 'Reply{command: $command, status: $status, statusMsg: $statusMsg, entries: $entries}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reply &&
          runtimeType == other.runtimeType &&
          command == other.command &&
          status == other.status &&
          statusMsg == other.statusMsg &&
          ListEquality().equals(entries, other.entries);

  @override
  int get hashCode =>
      command.hashCode ^
      status.hashCode ^
      statusMsg.hashCode ^
      ListEquality().hash(entries);
}
