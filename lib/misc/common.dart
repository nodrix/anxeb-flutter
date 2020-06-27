import 'key_value.dart';

typedef ResultCallback = dynamic Function();
typedef TextFieldFormatter = dynamic Function(String value);
typedef KeyValueCallback = Future<KeyValue> Function();
typedef ModelLoadedCallback<T> = Function(T data);