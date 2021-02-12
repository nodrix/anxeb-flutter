import 'package:flutter/material.dart' hide Overlay;
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'overlay.dart';
import 'scope.dart';
import 'utils.dart';

class Window {
  Scope _scope;
  Overlay _overlay;
  bool _isKeyboardActive;
  Size _available;

  Window(Scope scope) {
    _scope = scope;
    _overlay = Overlay(navigationDefaultFill: scope.application.settings.colors.navigation);
    this.update(context: context);
  }

  Window update({BuildContext context, BoxConstraints constraints}) {
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        _isKeyboardActive = visible;
        _scope.alerts.dispose(quick: true);
        _scope.rasterize();
      },
    );

    _available = constraints != null ? Size(constraints.maxWidth, constraints.maxHeight + (insets?.bottom ?? 0)) : size;
    return this;
  }

  double horizontal(double fraction) {
    return size.width * fraction;
  }

  double vertical(double fraction) {
    return size.height * fraction;
  }

  EdgeInsets padding({double left = 0.0, double top = 0.0, double right = 0.0, double bottom = 0.0}) {
    return Utils.convert.fromInsetToFraction(EdgeInsets.only(left: left, top: top, right: right, bottom: bottom), size);
  }

  Size get size => context != null ? MediaQuery.of(context).size : Size.zero;

  EdgeInsets get insets => context != null ? MediaQuery.of(context).viewInsets : null;

  Overlay get overlay => _overlay;

  BuildContext get context => _scope.context;

  bool get isKeyboardActive => _isKeyboardActive;

  Size get available => _available;
}
