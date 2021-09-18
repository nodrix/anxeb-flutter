import 'dart:convert';

class Data {
  dynamic _items;

  Data([data]) {
    if (data != null) {
      if (data is String) {
        _items = json.decode(data);
      } else if (data is Data) {
        _items = data._items;
      } else {
        _items = data;
      }
    } else {
      _items = {};
    }
  }

  dynamic operator [](key) {
    return _items[key];
  }

  void operator []=(key, value) {
    _items[key] = value;
  }

  int get length {
    return _items.length;
  }

  void include(Map<String, Object> data) {
    data.forEach((key, value) {
      _items[key] = value;
    });
  }

  List<T> map<T>(String field, T predicate(e)) {
    var list = _items[field] != null ? (_items[field] as List<dynamic>) : null;
    return list != null ? list.map(predicate).toList() : <T>[];
  }

  List<T> list<T>(T predicate(data), {String field}) {
    var list = (field != null && _items[field] != null ? _items[field] : _items) as List<dynamic>;
    return list != null ? list.map(predicate).toList() : <T>[];
  }

  Data clone() {
    return Data(toObjects());
  }

  bool isList() {
    return _items is List;
  }

  void $print() {
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(toJson(pretty: true)).forEach((match) => print(match.group(0)));
  }

  dynamic toObjects() {
    var result = {};
    for (var $items in _items.entries) {
      result[$items.key] = $items.value;
    }
    return result;
  }

  @override
  String toString() {
    return _items.toString();
  }

  void remove(String field) {
    Map items = _items as Map;
    items.remove(field);
  }

  String toJson({bool pretty}) {
    if (pretty == true) {
      var encoder = new JsonEncoder.withIndent('  ');
      return encoder.convert(toObjects());
    } else {
      return json.encode(toObjects());
    }
  }
}
