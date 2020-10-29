import 'reply.dart';
import 'argument.dart';

/// Event sent from the ECoS
class Event {
  /// id of the corresponding object
  final int id;
  /// The supplied argument
  // Subject to change (to list)?
  final Argument argument;

  Event({this.id, this.argument});

  factory Event.fromResponse(Reply resp) {
    return Event(
      id: int.parse(resp.extra),
      argument: resp.entries.first.parameters.first,
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
