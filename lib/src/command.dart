import 'package:collection/src/equality.dart';
import 'package:meta/meta.dart';
import 'parameter.dart';

class Command {
  final String type;
  final int id;
  final Set<Parameter> parameters;

  Command({@required this.type, @required this.id, this.parameters = const {}});

  String get str {
    var paramString = parameters.map((p) => p.str).join(', ');
    paramString = paramString.isEmpty ? '' : ', $paramString';
    return '$type($id$paramString)';
  }

  static final _cmdRegex =
      RegExp(r'^(?<type>\w+)\((?<id>\d+)([, ]+(?<params>.*))?\)$');

  factory Command.fromString(String str) {
    final match = _cmdRegex.firstMatch(str.trim());
    if (match == null) {
      throw ArgumentError.value(str, 'str', 'Not a valid command string');
    }

    final type = match.namedGroup('type');
    final id = int.parse(match.namedGroup('id'));
    final params = match.namedGroup('params');

    if (params == null) {
      return Command(type: type, id: id);
    }

    return Command(
        type: type, id: id, parameters: parameterListFromString(params));
  }

  static Set<Parameter> parameterListFromString(String str) {
    if (str == null || str.isEmpty) return {};
    final split = <Parameter>{};

    var lastSplit = 0;
    var quoteCount = 0;
    for (var i = 0; i < str.length; i++) {
      final char = str[i];
      if (char == '"') quoteCount++;
      if (char == ',' && quoteCount % 2 == 0) {
        split.add(Parameter.fromString(str.substring(lastSplit, i)));
        lastSplit = i + 1;
      }
    }
    split.add(Parameter.fromString(str.substring(lastSplit, str.length)));
    return split;
  }

  @override
  String toString() {
    return 'Command{type: $type, id: $id, parameters: $parameters}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Command &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          SetEquality().equals(parameters, other.parameters);

  @override
  int get hashCode => type.hashCode ^ id.hashCode ^ parameters.hashCode;
}