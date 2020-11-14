import 'package:collection/collection.dart';
import 'package:ecos_communicator/ecos_communicator.dart';

import 'listEntry.dart';
import 'response.dart';

/// Event sent by the ECoS
///
/// Syntax:
/// ```
/// <EVENT $id>
/// $id $argument
/// <END 0 (OK)>
/// ```
///
/// Example:
/// ```
/// <EVENT 20000>
/// 20000 state[1]
/// <END 0 (OK)>
/// ```
class Event {
  /// The id of the Reply
  final int id;

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

  /// Returns the first [Argument] from the first [Entry]
  Argument get argument {
    return entry.argument;
  }

  /// Creates a Reply with the supplied parameters
  Event({this.id, this.status, this.statusMsg, this.entries});

  /// Creates a [Event] from a [Response]
  factory Event.fromResponse(Response response) {
    assert(response.type == 'EVENT');
    return Event(
        id: int.parse(response.extra),
        status: response.status,
        statusMsg: response.statusMsg,
        entries: response.entries);
  }

  @override
  String toString() {
    return 'Event{id: $id, status: $status, statusMsg: $statusMsg, entries: $entries}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status &&
          statusMsg == other.statusMsg &&
          ListEquality().equals(entries, other.entries);

  @override
  int get hashCode =>
      id.hashCode ^
      status.hashCode ^
      statusMsg.hashCode ^
      ListEquality().hash(entries);
}
