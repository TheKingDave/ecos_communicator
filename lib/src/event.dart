import 'response.dart';
import 'parameter.dart';

class Event {
  final int id;
  // Subject to change?
  final Parameter parameter;

  Event({this.id, this.parameter});

  factory Event.fromResponse(Response resp) {
    return Event(
      id: int.parse(resp.extra),
      parameter: resp.lines.first.parameters.first,
    );
  }

  @override
  String toString() {
    return 'Event{id: $id, parameter: $parameter}';
  }
}
