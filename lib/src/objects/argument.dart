import 'package:meta/meta.dart';

/// An ECoS argument for a request
///
/// Syntax: `$name` | `$name[$value]` | `$name["$value"]`
///
/// Examples:
/// * `state`
/// * `state[1]`
/// * `name1["Switch 1"]`
///
class Argument {
  /// The name of the argument (option)
  final String name;

  /// The value of the argument (parameter)
  final String value;

  /// The type of the parameter
  final ArgumentType type;

  /// Constructs an argument
  ///
  /// Throws an [ArgumentError] if the type is [ArgumentType.NATIVE] or [ArgumentType.STRING] and no value
  /// is supplied
  Argument({@required this.name, this.value, this.type = ArgumentType.NATIVE}) {
    if (type != ArgumentType.NO_VALUE && value == null) {
      throw ArgumentError('If type is not NO_VALUE a value must be provided.');
    }
  }

  /// Constructs an argument of the type NATIVE
  factory Argument.native(String name, String value) {
    return Argument(name: name, value: value, type: ArgumentType.NATIVE);
  }

  /// Constructs an argument of the type STRING
  factory Argument.string(String name, String value) {
    return Argument(name: name, value: value, type: ArgumentType.STRING);
  }

  /// Constructs an argument of the type NO_VALUE
  factory Argument.name(String name) {
    return Argument(name: name, type: ArgumentType.NO_VALUE);
  }

  static final _paramRegex = RegExp(r'^(?<name>[^\[]+)(\[(?<value>.+)\])?$');

  /// Parse argument from string
  ///
  /// Throws an [ArgumentError] if the string is not properly formatted
  factory Argument.fromString(String str) {
    final match = _paramRegex.firstMatch(str.trim());
    if (match == null) {
      throw ArgumentError.value(str, 'str', 'Not a valid parameter string');
    }

    final name = match.namedGroup('name');
    final value = match.namedGroup('value');

    if (value == null) {
      return Argument(name: name, type: ArgumentType.NO_VALUE);
    }

    if (value[0] == '"' && value[value.length - 1] == '"') {
      return Argument(
          name: name,
          value: value.substring(1, value.length - 1).replaceAll('""', '"'),
          type: ArgumentType.STRING);
    }

    return Argument(name: match.namedGroup('name'), value: value);
  }

  /// If the [type] is STRING the value is properly escaped
  ///
  ///
  String get escapedValue {
    if (type == ArgumentType.STRING) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Returns the ECoS string representation of the an Argument
  String get str {
    if (type == ArgumentType.NO_VALUE) {
      return name;
    }
    return '$name[$escapedValue]';
  }

  @override
  String toString() {
    final t = type.toString().substring(13);
    if (type == ArgumentType.NO_VALUE) {
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

/// Type enum for Arguments
// ignore: public_member_api_docs
enum ArgumentType { NATIVE, STRING, NO_VALUE }
