import 'package:meta/meta.dart';

class Argument {
  final String name;
  final String value;
  final ParameterType type;

  Argument(
      {@required this.name, this.value, this.type = ParameterType.NATIVE}) {
    if (type != ParameterType.NO_VALUE && value == null) {
      throw ArgumentError('If type is not NO_VALUE a value must be provided.');
    }
  }

  factory Argument.native(String name, String value) {
    return Argument(name: name, value: value, type: ParameterType.NATIVE);
  }

  factory Argument.string(String name, String value) {
    return Argument(name: name, value: value, type: ParameterType.STRING);
  }

  factory Argument.name(String name) {
    return Argument(name: name, type: ParameterType.NO_VALUE);
  }

  static final _paramRegex = RegExp(r'^(?<name>[^\[]+)(\[(?<value>.+)\])?$');

  factory Argument.fromString(String str) {
    final match = _paramRegex.firstMatch(str.trim());
    if (match == null) {
      throw ArgumentError.value(str, 'str', 'Not a valid parameter string');
    }

    final name = match.namedGroup('name');
    final value = match.namedGroup('value');

    if (value == null) {
      return Argument(name: name, type: ParameterType.NO_VALUE);
    }

    if (value[0] == '"' && value[value.length - 1] == '"') {
      return Argument(
          name: name,
          value: value.substring(1, value.length - 1).replaceAll('""', '"'),
          type: ParameterType.STRING);
    }

    return Argument(name: match.namedGroup('name'), value: value);
  }

  String get escapedValue {
    if (type == ParameterType.STRING) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String get str {
    if (type == ParameterType.NO_VALUE) {
      return name;
    }
    return '$name[$escapedValue]';
  }

  @override
  String toString() {
    final t = type.toString().substring(14);
    if(type == ParameterType.NO_VALUE) {
      return 'Parameter{name: $name, type: $t}';
    }
    return 'Parameter{name: $name, value: $value, type: $t}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Argument &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          value == other.value &&
          type == other.type;

  @override
  int get hashCode => name.hashCode ^ value.hashCode ^ type.hashCode;
}

enum ParameterType { NATIVE, STRING, NO_VALUE }