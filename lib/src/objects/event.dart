import 'reply.dart';
import 'argument.dart';

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
  /// id of the corresponding object
  final int id;

  /// The supplied argument
  // Subject to change (to list)?
  final Argument argument;

  /// Constructs a Event
  ///
  /// This is merely a data holding class
  Event({this.id, this.argument});

  /// Parses an [Event] from a [Reply]
  factory Event.fromResponse(Reply reply) {
    return Event(
      id: int.parse(reply.extra),
      argument: reply.entries.first.parameters.first,
    );
  }

  @override
  String toString() {
    return 'Event{id: $id, parameter: $argument}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}