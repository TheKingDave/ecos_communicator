import 'response.dart';
import 'parameter.dart';
import 'responseLine.dart';

class Event {
  final int id;
  final Parameter parameter;

  Event({this.id, this.parameter});

  factory Event.fromResponse(Response resp) {
    return Event(
      id: int.parse(resp.extra),
      parameter: ResponseLine.fromString(resp.lines.first).parameter,
    );
  }

  @override
  String toString() {
    return 'Event{id: $id, parameter: $parameter}';
  }
}
