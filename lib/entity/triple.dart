class Triple<T1, T2, T3> {
  Triple(this.left, this.middle, this.right);

  final T1 left;
  final T2 right;
  final T3 middle;

  @override
  String toString() => 'Triple[$left, $middle, $right]';
}
