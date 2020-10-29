import 'package:collection/src/equality.dart';
import 'package:meta/meta.dart';
import 'argument.dart';

class Request {
  final String type;
  final int id;
  final Set<Argument> parameters;

  Request({@required this.type, @required this.id, this.parameters = const {}});

  factory Request.get(int id, [Set<Argument> parameters = const {}]) =>
      Request(type: 'get', id: id, parameters: parameters);

  factory Request.set(int id, [Set<Argument> parameters = const {}]) =>
      Request(type: 'set', id: id, parameters: parameters);

  factory Request.create(int id, [Set<Argument> parameters = const {}]) =>
      Request(type: 'create', id: id, parameters: parameters);

  factory Request.delete(int id, [Set<Argument> parameters = const {}]) =>
      Request(type: 'delete', id: id, parameters: parameters);

  factory Request.request(int id, [Set<Argument> parameters = const {}]) =>
      Request(type: 'request', id: id, parameters: parameters);

  factory Request.release(int id, [Set<Argument> parameters = const {}]) =>
      Request(type: 'release', id: id, parameters: parameters);

  factory Request.link(int id, [Set<Argument> parameters = const {}]) =>
      Request(type: 'link', id: id, parameters: parameters);

  factory Request.unlink(int id, [Set<Argument> parameters = const {}]) =>
      Request(type: 'unlink', id: id, parameters: parameters);

  factory Request.queryObjects(int id,
          [Set<Argument> parameters = const {}]) =>
      Request(type: 'queryObjects', id: id, parameters: parameters);

  String get str {
    var paramString = parameters.map((p) => p.str).join(',');
    paramString = paramString.isEmpty ? '' : ',$paramString';
    return '$type($id$paramString)';
  }

  static final _cmdRegex =
      RegExp(r'^(?<type>\w+)\((?<id>\d+)([, ]+(?<params>.*))?\)$');

  factory Request.fromString(String str) {
    final match = _cmdRegex.firstMatch(str.trim());
    if (match == null) {
      throw ArgumentError.value(str, 'str', 'Not a valid command string');
    }

    final type = match.namedGroup('type');
    final id = int.parse(match.namedGroup('id'));
    final params = match.namedGroup('params');

    if (params == null) {
      return Request(type: type, id: id);
    }

    return Request(
        type: type, id: id, parameters: _parameterListFromString(params));
  }

  static Set<Argument> _parameterListFromString(String str) {
    if (str == null || str.isEmpty) return {};
    final split = <Argument>{};

    var lastSplit = 0;
    var quoteCount = 0;
    var inBrackets = false;

    for (var i = 0; i < str.length; i++) {
      final char = str[i];
      if (char == '"') {
        quoteCount++;
        continue;
      }

      if (quoteCount % 2 == 0) continue;

      if (char == '[') inBrackets = true;
      if (char == ']') inBrackets = false;

      if (inBrackets) continue;

      if (char == ',') {
        split.add(Argument.fromString(str.substring(lastSplit, i)));
        lastSplit = i + 1;
      }
    }
    split.add(Argument.fromString(str.substring(lastSplit, str.length)));
    return split;
  }

  @override
  String toString() {
    return 'Command{type: $type, id: $id, parameters: $parameters}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Request &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          SetEquality().equals(parameters, other.parameters);

  @override
  int get hashCode => type.hashCode ^ id.hashCode ^ parameters.hashCode;
}
