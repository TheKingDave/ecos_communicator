import 'package:collection/collection.dart';

import 'argument.dart';

class ListEntry {
  final int id;
  final List<Argument> parameters;

  ListEntry({this.id, this.parameters});

  factory ListEntry.fromString(String str) {
    final split = str.split(' ');
    final id = int.parse(split.removeAt(0));
    final parameters = split.map((e) => Argument.fromString(e)).toList();
    return ListEntry(id: id, parameters: parameters);
  }

  @override
  String toString() {
    return 'ResponseLine{id: $id, parameter: $parameters}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          ListEquality().equals(parameters, other.parameters);

  @override
  int get hashCode => id.hashCode ^ parameters.hashCode;
}