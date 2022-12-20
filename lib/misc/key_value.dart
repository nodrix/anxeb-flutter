class KeyValue<T> {
  KeyValue(this.key, this.value);

  final String key;
  final T value;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is KeyValue<T> && other.value == value;
  }

  @override
  String toString() {
    final String valueString = T == String ? "<'$value'>" : '<$value>';
    return '$key : $valueString';
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);
}
