import 'package:flutter/material.dart';

typedef ReferenceLoaderHandler<T> = Future<List<T>> Function(ReferencerPage<T> page, [T value]);
typedef ReferenceComparerHandler<T> = bool Function(T a, T b);
typedef ReferenceItemWidget<T> = Widget Function(ReferencerPage<T> page, T item);
typedef ReferenceHeaderWidget<T> = Widget Function(ReferencerPage<T> page);
typedef ReferenceCreateWidget<T> = Widget Function(ReferencerPage<T> page);
typedef ReferenceEmptyWidget<T> = Widget Function(ReferencerPage<T> page);

class Referencer<V> {
  final ReferenceLoaderHandler<V> loader;
  final ReferenceComparerHandler<V> comparer;
  Function() updater;
  int currentPage;
  PageController _pagesController;
  ReferencerPage<V> _root;
  Function(List<V> result) _onSubmit;

  Referencer({this.loader, this.comparer, this.updater}) {
    _pagesController = PageController(initialPage: 0);
  }

  Future init() async {
    _root = ReferencerPage<V>(referencer: this);
    await _root.refresh();
  }

  List<ReferencerPage<V>> get pages {
    var result = <ReferencerPage<V>>[];
    var $next = _root;
    while ($next != null) {
      result.add($next);
      $next = $next?.next;
    }
    return result;
  }

  Future start() async {
    await controller.animateToPage(0, duration: Duration(milliseconds: 500), curve: Curves.easeInOutExpo);
    updater?.call();
    return;
  }

  Future back() async {
    if (currentPage > 0) {
      await controller.animateToPage(currentPage - 1, duration: Duration(milliseconds: 500), curve: Curves.easeInOutExpo);
      updater?.call();
    }
    return;
  }

  void onSubmit(Function(List<V> result) onSubmit) => _onSubmit = onSubmit;

  int get count => pages.length;

  PageController get controller => _pagesController;
}

class ReferencerPage<V> {
  ReferencerPage<V> _parent;
  ReferencerPage<V> _next;
  List<V> _items;
  V _selected;
  Referencer<V> _manager;
  bool _busy;

  ReferencerPage({Referencer<V> referencer, ReferencerPage<V> parent}) {
    _manager = referencer;
    _parent = parent;
  }

  Future<bool> select(V item) async {
    if (_manager.comparer != null) {
      _selected = _items?.firstWhere(($item) => _manager.comparer($item, item), orElse: () => null);
    } else {
      _selected = _items?.firstWhere(($item) => $item == item, orElse: () => null);
    }
    if (_selected != null) {
      var page = ReferencerPage<V>(referencer: _manager, parent: this);
      _busy = true;
      _manager?.updater?.call();

      try {
        var alive = await page.refresh();
        if (!alive) {
          _busy = false;
          _manager?.updater?.call();
          _manager?._onSubmit?.call(_getValues());
          return true;
        }
      } catch (err) {
        _busy = false;
        _manager?.updater?.call();
        throw err;
      }
      _next = page;
      _busy = false;
      _manager?.updater?.call();
      await _next.show();
      _manager?.updater?.call();
    }
    return false;
  }

  Future show() async {
    var $pages = _manager.pages;
    var i = 0;
    for (var page in $pages) {
      if (page == this) {
        await _manager.controller.animateToPage(i, duration: Duration(milliseconds: 500), curve: Curves.easeInOutExpo);
        _manager?.updater?.call();
        return;
      }
      i++;
    }
  }

  Future<bool> refresh() async {
    _busy = true;
    _manager?.updater?.call();
    _items = await _manager.loader(this, _parent?.selected);
    _busy = false;
    _manager?.updater?.call();
    return _items != null;
  }

  bool isSelected(V item) {
    if (_manager.comparer != null) {
      return _manager.comparer(selected, item);
    } else {
      return selected == item;
    }
  }

  bool isBusy(V item) {
    return busy && isSelected(item);
  }

  List<V> _getValues() {
    var result = <V>[];
    var $parent = this;
    while ($parent != null) {
      if ($parent.selected != null) {
        result.add($parent.selected);
      }
      $parent = $parent.parent;
    }
    return result.reversed.toList();
  }

  ReferencerPage<V> get parent => _parent;

  ReferencerPage<V> get next => _next;

  V get selected => _selected;

  List<V> get items => _items ?? [];

  bool get busy => _busy != null ? _busy : false;

  bool get idle => !busy;
}
