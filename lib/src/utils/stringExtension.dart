/// Adds an split method to String which supports quoting
extension SplitQuotes on String {
  /// Splits a String with support of quoting
  ///
  /// The parameters are only allowed to be one character long because of the
  /// implementation of the algorithm
  ///
  /// Quoted [quoteChar] are archived by doubling it e.q. `Hello ""David""`
  /// => [Hello, "David"]
  List<String> splitWithQuotes(String splitChar, [String quoteChar = '"']) {
    if (isEmpty) return [];
    if (splitChar.length != 1) {
      throw ArgumentError.value(
          splitChar, 'splitChar', 'Only works with 1 character long spliters');
    }
    if (quoteChar.length != 1) {
      throw ArgumentError.value(
          quoteChar, 'quoteChar', 'Must be exactly 1 character long');
    }
    final split = <String>[];

    var lastSplit = 0;
    var inQuotes = false;
    var quoteCount = 0;
    for (var i = 0; i < length; i++) {
      final char = this[i];
      if (char == quoteChar) quoteCount++;
      if (char != quoteChar && quoteCount > 0) {
        if (quoteCount % 2 != 0) inQuotes = !inQuotes;
        quoteCount = 0;
      }
      if (char == splitChar && !inQuotes) {
        split.add(substring(lastSplit, i).trim());
        lastSplit = i + 1;
      }
    }
    split.add(substring(lastSplit, length).trim());
    return split;
  }
}
