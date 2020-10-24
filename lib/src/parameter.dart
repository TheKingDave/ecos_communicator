import 'package:meta/meta.dart';

class Parameter {
  final String name;
  final String _value;
  final ParameterType type;

  Parameter(
      {@required this.name, String value, this.type = ParameterType.NATIVE})
      : _value = value {
    if (type != ParameterType.NO_VALUE && value == null) {
      throw ArgumentError('If type is not NO_VALUE a value must be provided.');
    }
  }

  factory Parameter.native(String name, String value) {
    return Parameter(name: name, value: value, type: ParameterType.NATIVE);
  }

  factory Parameter.string(String name, String value) {
    return Parameter(name: name, value: value, type: ParameterType.STRING);
  }

  factory Parameter.noValue(String name) {
    return Parameter(name: name, type: ParameterType.NO_VALUE);
  }

  static final _paramRegex = RegExp(r'^(?<name>[^\[]+)(\[(?<value>.+)\])?$');

  factory Parameter.fromString(String str) {
    final match = _paramRegex.firstMatch(str.trim());
    if (match == null) {
      throw ArgumentError.value(str, 'str', 'Not a valid parameter string');
    }

    final name = match.namedGroup('name');
    final value = match.namedGroup('value');

    if (value == null) {
      return Parameter(name: name, type: ParameterType.NO_VALUE);
    }

    if (value[0] == '"' && value[value.length - 1] == '"') {
      return Parameter(
          name: name,
          value: value.substring(1, value.length - 1).replaceAll('""', '"'),
          type: ParameterType.STRING);
    }

    return Parameter(name: match.namedGroup('name'), value: value);
  }

  String get value {
    if (type == ParameterType.STRING) {
      return '"${_value.replaceAll('"', '""')}"';
    }
    return _value;
  }

  String get str {
    if (type == ParameterType.NO_VALUE) {
      return name;
    }
    return '$name[$value]';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Parameter &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          _value == other._value &&
          type == other.type;

  @override
  int get hashCode => name.hashCode ^ _value.hashCode ^ type.hashCode;

  @override
  String toString() {
    return 'Parameter{name: $name, _value: $_value, type: $type}';
  }
}

enum ParameterType { NATIVE, STRING, NO_VALUE }
