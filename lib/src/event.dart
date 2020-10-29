import 'reply.dart';
import 'argument.dart';

class Event {
  final int id;
  // Subject to change (to list)?
  final Argument parameter;

  Event({this.id, this.parameter});

  factory Event.fromResponse(Reply resp) {
    return Event(
      id: int.parse(resp.extra),
      parameter: resp.lines.first.parameters.first,
    );
  }

  @override
  String toString() {
    return 'Event{id: $id, parameter: $parameter}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
