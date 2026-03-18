import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/settings.dart';
import 'package:anxeb_flutter/widgets/buttons/text.dart';
import 'package:flutter/material.dart' hide Dialog, TextButton;
import 'package:flutter_translate/flutter_translate.dart';
import 'period.dart';

class PeriodsDialog extends ScopeDialog {
  final String title;
  final IconData icon;
  final List<PeriodValue> selectedValues;
  final double buttonsWidth;
  final double width;
  final double height;
  List<PeriodValue> _values = [];

  PeriodsDialog(
    Scope scope, {
    this.title,
    this.icon,
    this.selectedValues,
    this.buttonsWidth,
    this.width,
    this.height,
  })  : assert(title != null),
        super(scope) {
    super.dismissible = true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(scope.application.settings.dialogs.dialogRadius ?? 20.0))),
      contentPadding: EdgeInsets.only(bottom: 20, left: 24, right: 24, top: 5),
      contentTextStyle: TextStyle(fontSize: title != null ? 16.4 : 20, color: scope.application.settings.colors.text, fontWeight: FontWeight.w400),
      title: icon != null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(right: 7),
                    child: Icon(
                      icon,
                      size: 29,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: EdgeInsets.only(bottom: 10),
              child: new Text(
                title ?? scope.title,
                textAlign: TextAlign.center,
              ),
            ),
      content: Container(
        //height: height ?? scope.window.vertical(0.6),
        //width: width ?? scope.window.available.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            PeriodsSelector(
              scope: scope,
              values: selectedValues,
              selectedFillColor: scope.application.settings.colors.active,
              selectedTextColor: scope.application.settings.colors.primary,
              onValuesChanged: (values) {
                _values = values;
              },
            ),
            Container(
              padding: EdgeInsets.only(top: 10, left: 4, right: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: TextButton.createList(
                  context,
                  [
                    DialogButton(
                      translate('anxeb.common.cancel'),
                      null,
                      onTap: (context) async => Navigator.of(context).pop(null),
                    ),
                    DialogButton(
                      translate('anxeb.common.accept'),
                      null,
                      onTap: (context) async => Navigator.of(context).pop(_values),
                    ),
                  ],
                  settings: scope.application.settings,
                  width: buttonsWidth ?? 100,
                ),
              ),
            )
          ],
        ),
      ),
      /*content: Container(
        child: PeriodsSelector(
          scope: scope,
          values: selectedValues,
          selectedFillColor: scope.application.settings.colors.active,
          selectedTextColor: scope.application.settings.colors.primary,
        ),
      ),*/
    );
  }
}

class PeriodsSelector extends StatefulWidget {
  final Scope scope;
  final List<PeriodValue> values;
  final Color selectedFillColor;
  final Color selectedTextColor;
  final Function(List<PeriodValue> values) onValuesChanged;

  PeriodsSelector({
    @required this.scope,
    this.values,
    this.selectedFillColor = Colors.blue,
    this.selectedTextColor = Colors.white,
    this.onValuesChanged,
  });

  @override
  _PeriodsSelectorState createState() => _PeriodsSelectorState();
}

class _PeriodsSelectorState extends State<PeriodsSelector> {
  List<PeriodValue> _values = [];
  List<int> _years = [];
  List<int> _months = [];
  var _monthsNames = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

  @override
  initState() {
    for (var i = currentYear; i > currentYear - 4; i--) {
      _years.add(i);
    }
    _months = List.generate(12, (i) => i + 1);

    if (widget.values != null) {
      _values = widget.values;
    } else {
      for (var i = 1; i <= currentMonth; i++) {
        _values.add(PeriodValue(year: currentYear, month: i));
      }
    }
    widget.onValuesChanged?.call(_values);
    super.initState();
  }

  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _years.map((year) {
        return Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: settings.colors.separator, width: 1)),
              ),
              child: Row(
                children: [
                  Text(
                    year.toString(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: settings.colors.text),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: year != _years.last ? 18 : 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _months.map((month) {
                  var activeMonth = _values != null && _values.any((v) => v.year == year && v.month == month);
                  var monthName = month <= _monthsNames.length ? _monthsNames[month - 1] : month.toString();

                  return TextButton(
                    caption: monthName,
                    radius: settings.dialogs.buttonRadius,
                    textColor: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    borderColor: settings.colors.primary,
                    //type: ButtonType.frame,
                    type: ButtonType.primary,
                    color: activeMonth ? settings.colors.primary : settings.colors.primary.withOpacity(0.5),

                    margin: EdgeInsets.only(right: month != _months.last ? 5 : 0, bottom: 4, top: 4),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    onPressed: () {
                      setState(() {
                        if (activeMonth) {
                          _values.removeWhere((v) => v.year == year && v.month == month);
                        } else {
                          _values.add(PeriodValue(year: year, month: month));
                        }
                        widget.onValuesChanged?.call(_values);
                      });
                    },
                    size: ButtonSize.small,
                    textStyle: widget.scope.application.settings.dialogs.buttonTextStyle,
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Settings get settings => widget.scope.application.settings;

  int get currentYear => DateTime.now().year;

  int get currentMonth => DateTime.now().month;
}
