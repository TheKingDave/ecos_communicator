import 'package:collection/src/equality.dart';
import 'package:meta/meta.dart';
import 'argument.dart';

/// ECoS request
/// 
/// Syntax: `$command($id, $arguments...)`
/// 
/// Examples:
/// * `get(1, info)`
/// * `set(20000, state[1], name1["Line 1"], name2["Line 2"], name3["Line 3"])`
/// * `reqeust(1000, view)`
class Request {
  /// The command of the request (cmd)
  final String command;

  /// The id of the object
  final int id;

  /// The argument list
  final Set<Argument> arguments;

  /// Creates a [Request] with the supplied [command], [id] and [arguments]
  Request(
      {@required this.command, @required this.id, this.arguments = const {}});

  /// Construct a get request
  factory Request.get(int id, [Set<Argument> arguments = const {}]) =>
      Request(command: 'get', id: id, arguments: arguments);

  /// Construct a set request
  factory Request.set(int id, [Set<Argument> arguments = const {}]) =>
      Request(command: 'set', id: id, arguments: arguments);

  /// Construct a create request
  factory Request.create(int id, [Set<Argument> arguments = const {}]) =>
      Request(command: 'create', id: id, arguments: arguments);

  /// Construct a delete request
  factory Request.delete(int id, [Set<Argument> arguments = const {}]) =>
      Request(command: 'delete', id: id, arguments: arguments);

  /// Construct a request request
  factory Request.request(int id, [Set<Argument> arguments = const {}]) =>
      Request(command: 'request', id: id, arguments: arguments);

  /// Construct a release request
  factory Request.release(int id, [Set<Argument> arguments = const {}]) =>
      Request(command: 'release', id: id, arguments: arguments);

  /// Construct a link request
  factory Request.link(int id, [Set<Argument> arguments = const {}]) =>
      Request(command: 'link', id: id, arguments: arguments);

  /// Construct a unlink request
  factory Request.unlink(int id, [Set<Argument> arguments = const {}]) =>
      Request(command: 'unlink', id: id, arguments: arguments);

  /// Construct a queryObjects request
  factory Request.queryObjects(int id, [Set<Argument> arguments = const {}]) =>
      Request(command: 'queryObjects', id: id, arguments: arguments);

  /// Parse request from string
  factory Request.fromString(String str) {
    final match = _cmdRegex.firstMatch(str.trim());
    if (match == null) {
      throw ArgumentError.value(str, 'str', 'Not a valid command string');
    }

    final type = match.namedGroup('type');
    final id = int.parse(match.namedGroup('id'));
    final params = match.namedGroup('params');

    if (params == null) {
      return Request(command: type, id: id);
    }

    return Request(
        command: type, id: id, arguments: _parameterListFromString(params));
  }

  /// The ECoS string representation
  String get str {
    var paramString = arguments.map((p) => p.str).join(',');
    paramString = paramString.isEmpty ? '' : ',$paramString';
    return '$command($id$paramString)';
  }

  static final _cmdRegex =
      RegExp(r'^(?<type>\w+)\((?<id>\d+)([, ]+(?<params>.*))?\)$');

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

      if (quoteCount % 2 == 1) continue;

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
    return 'Command{type: $command, id: $id, arguments: $arguments}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Request &&
          runtimeType == other.runtimeType &&
          command == other.command &&
          id == other.id &&
          SetEquality().equals(arguments, other.arguments);

  @override
  int get hashCode => command.hashCode ^ id.hashCode ^ arguments.hashCode;
}
