class Tuple<T0, T1> {
  final T0 item0;
  final T1 item1;

  Tuple(this.item0, this.item1);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Tuple && runtimeType == other.runtimeType && item0 == other.item0 && item1 == other.item1;

  @override
  int get hashCode => item0.hashCode ^ item1.hashCode;
}