import 'parameter.dart';

class ResponseLine {
  final int id;
  final Parameter parameter;

  ResponseLine({this.id, this.parameter});

  factory ResponseLine.fromString(String str) {
    final idx = str.indexOf(' ');
    final id = int.parse(str.substring(0, idx));
    final parameter = Parameter.fromString(str.substring(idx+1));
    return ResponseLine(id: id, parameter: parameter);
  }

  @override
  String toString() {
    return 'ResponseLine{id: $id, parameter: $parameter}';
  }
}