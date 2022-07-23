import 'dart:math' as math;
import 'package:flutter/material.dart';

const double kFloatingActionButtonMargin = 16.0;

double _leftOffset(ScaffoldPrelayoutGeometry scaffoldGeometry, {double offset = 0.0}) {
  return kFloatingActionButtonMargin + scaffoldGeometry.minInsets.left - offset;
}

double _rightOffset(ScaffoldPrelayoutGeometry scaffoldGeometry, {double offset = 0.0}) {
  return scaffoldGeometry.scaffoldSize.width - kFloatingActionButtonMargin - scaffoldGeometry.minInsets.right - scaffoldGeometry.floatingActionButtonSize.width + offset;
}

double _endOffset(ScaffoldPrelayoutGeometry scaffoldGeometry, {Alignment alignment, double offset = 0.0}) {
  assert(scaffoldGeometry.textDirection != null);
  if (alignment != null && alignment == Alignment.bottomLeft || scaffoldGeometry.textDirection == TextDirection.rtl) {
    return _leftOffset(scaffoldGeometry, offset: offset);
  } else if (alignment != null && alignment == Alignment.bottomRight || scaffoldGeometry.textDirection == TextDirection.ltr) {
    return _rightOffset(scaffoldGeometry, offset: offset);
  }
  return null;
}

class ViewActionLocator extends FloatingActionButtonLocation {
  final Offset offset;
  final Alignment alignment;
  double _altOffset;

  ViewActionLocator({
    this.offset,
    this.alignment,
  });

  @protected
  double getDockedY(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double bottomSheetHeight = scaffoldGeometry.bottomSheetSize.height;
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height - (_altOffset ?? 0);
    final double contentBottom = scaffoldGeometry.scaffoldSize.height - (fabHeight / 2) - 19;
    final double snackBarHeight = scaffoldGeometry.snackBarSize.height;

    double fabY = contentBottom - fabHeight / 2.0;
    if (snackBarHeight > 0.0) {
      fabY = math.min(fabY, contentBottom - snackBarHeight - (fabHeight / 2));
    }
    if (bottomSheetHeight > 0.0) fabY = math.min(fabY, contentBottom - bottomSheetHeight - fabHeight / 2.0);

    final double maxFabY = scaffoldGeometry.scaffoldSize.height - fabHeight;
    return math.min(maxFabY, fabY + (offset != null ? offset.dy : 0));
  }

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = _endOffset(
      scaffoldGeometry,
      alignment: alignment,
      offset: offset != null ? offset.dx : 0,
    );
    return Offset(fabX, getDockedY(scaffoldGeometry));
  }

  void setAltOffset(double value) {
    _altOffset = value;
  }
}
