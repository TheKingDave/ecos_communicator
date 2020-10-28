import 'parameter.dart';

class ResponseLine {
  final int id;
  final List<Parameter> parameters;

  ResponseLine({this.id, this.parameters});

  factory ResponseLine.fromString(String str) {
    final split = str.split(' ');
    final id = int.parse(split.removeAt(0));
    final parameters = split.map((e) => Parameter.fromString(e)).toList();
    return ResponseLine(id: id, parameters: parameters);
  }

  @override
  String toString() {
    return 'ResponseLine{id: $id, parameter: $parameters}';
  }
}