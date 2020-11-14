import 'package:collection/collection.dart';

import 'argument.dart';

/// A ECoS ListEntry
///
/// Syntax: `$id $argument...`
///
/// Example: `20000 state[1]`
class ListEntry {
  /// The object id
  final int id;

  /// The argument list ([Argument]*)
  final List<Argument> arguments;

  /// Get the first argument of the ListEntry
  Argument get argument {
    return arguments.first;
  }

  /// Constructs a [ListEntry]
  ListEntry({this.id, this.arguments});

  /// Constructs a ListEntry from string
  factory ListEntry.fromString(String str) {
    final split = str.split(' ');
    final id = int.parse(split.removeAt(0));
    final parameters = split.map((e) => Argument.fromString(e)).toList();
    return ListEntry(id: id, arguments: parameters);
  }

  @override
  String toString() {
    return 'ListEntry{id: $id, parameter: $arguments}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          ListEquality().equals(arguments, other.arguments);

  @override
  int get hashCode => id.hashCode ^ arguments.hashCode;
}
