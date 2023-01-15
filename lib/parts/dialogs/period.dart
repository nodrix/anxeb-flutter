import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/middleware/settings.dart';
import 'package:anxeb_flutter/middleware/utils.dart';
import 'package:anxeb_flutter/widgets/buttons/text.dart';
import 'package:flutter/material.dart' hide Dialog, TextButton;
import 'package:flutter_translate/flutter_translate.dart';

class PeriodDialog extends ScopeDialog {
  final String title;
  final IconData icon;
  final PeriodValue selectedValue;
  final bool allowAllMonths;

  PeriodDialog(Scope scope, {this.title, this.icon, this.selectedValue, this.allowAllMonths})
      : assert(title != null),
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
        child: PeriodSelector(
          scope: scope,
          selected: selectedValue,
          allowAllMonths: allowAllMonths,
          onTap: (value) {
            Navigator.of(context).pop(value);
          },
        ),
      ),
    );
  }
}

class PeriodSelector extends StatefulWidget {
  final Scope scope;
  final PeriodValue selected;
  final Function(PeriodValue value) onTap;
  final bool allowAllMonths;

  PeriodSelector({@required this.scope, this.selected, this.onTap, this.allowAllMonths});

  @override
  _PeriodSelectorState createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<PeriodSelector> {
  final List<int> _verticals = [1, 2, 3, 4, 5, 6, 0];
  final List<int> _horizontals = [1, 2];
  List<int> _years = [];
  int _selectedYear;
  int _selectedMonth;

  @override
  void setState(fn) {
    for (var i = currentYear - 3; i <= currentYear; i++) {
      _years.add(i);
    }
    if (_selectedMonth == null) {
      _selectedMonth = widget?.selected?.month ?? currentMonth;
    }

    if (_selectedYear == null) {
      _selectedYear = widget.selected?.year ?? currentYear;
    }
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    _selectedYear = _selectedYear ?? widget?.selected?.year ?? currentYear;
    _selectedMonth = _selectedMonth ?? widget?.selected?.month;
    var activeMonth = (widget?.selected?.year ?? currentYear) == _selectedYear;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _years.map(($year) {
              return TextButton(
                caption: $year.toString(),
                radius: settings.dialogs.buttonRadius,
                textColor: _selectedYear == $year ? settings.colors.active : null,
                color: _selectedYear == $year ? settings.colors.primary : settings.colors.secudary,
                margin: EdgeInsets.symmetric(vertical: 5),
                onPressed: () {
                  setState(() {
                    _selectedYear = $year;
                    _selectedMonth = null;
                  });
                },
                type: ButtonType.primary,
                size: ButtonSize.small,
              );
            }).toList()),
        Container(
          margin: EdgeInsets.only(top: 8),
          padding: EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 1.0, color: settings.colors.separator),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _verticals.map((v) {
              if (v == 0) {
                if (widget.allowAllMonths == false) {
                  return Container();
                }
                return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 12),
                      child: TextButton(
                        caption: translate('anxeb.parts.dialogs.period.all_month'),
                        //TR 'Todos los Meses',
                        radius: settings.dialogs.buttonRadius,
                        textColor: activeMonth && _selectedMonth == null ? settings.colors.active : null,
                        color: activeMonth && _selectedMonth == null ? settings.colors.primary : settings.colors.secudary,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        onPressed: () {
                          setState(() {
                            _selectedMonth = null;
                          });
                          widget?.onTap?.call(PeriodValue(
                            year: _selectedYear,
                            month: _selectedMonth,
                          ));
                        },
                        type: ButtonType.primary,
                        size: ButtonSize.small,
                      ),
                    ),
                  )
                ]);
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _horizontals.map((h) {
                  var $month = ((v - 1) * _horizontals.length) + h;

                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: h == 1 ? 5 : 0, left: h > 1 ? 5 : 0),
                      child: TextButton(
                        caption: Utils.convert.fromIndexToMonth($month),
                        radius: settings.dialogs.buttonRadius,
                        textColor: activeMonth && _selectedMonth == $month ? settings.colors.active : null,
                        color: activeMonth && _selectedMonth == $month ? settings.colors.primary : settings.colors.secudary,
                        margin: EdgeInsets.symmetric(vertical: 5),
                        onPressed: () {
                          setState(() {
                            _selectedMonth = $month;
                          });
                          widget?.onTap?.call(PeriodValue(
                            year: _selectedYear,
                            month: _selectedMonth,
                          ));
                        },
                        type: ButtonType.primary,
                        size: ButtonSize.small,
                      ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  Settings get settings => widget.scope.application.settings;

  int get currentYear => DateTime.now().year;

  int get currentMonth => DateTime.now().month;
}

class PeriodValue {
  int _year;
  int _month;

  PeriodValue({int year, int month}) {
    _year = year;
    _month = month;
  }

  PeriodValue.now({bool allMonths}) {
    _year = DateTime.now().year;
    _month = allMonths == true ? null : DateTime.now().month;
  }

  dynamic toObject() {
    return {
      'year': _year,
      'month': _month,
    };
  }

  @override
  String toString({bool light}) {
    if (_year != null) {
      if (_month != null) {
        return (light != true ? '${translate('anxeb.parts.dialogs.period.to_string_prefix')} ' : '') + '${Utils.convert.fromIndexToMonth(_month)} $_year'; //TR Período
      }
      return '${translate('anxeb.parts.dialogs.period.year_prefix')} $_year';
    }
    return null;
  }

  void setCurrentMonth() {
    _month = DateTime.now().month;
  }

  int get year => _year;

  int get month => _month;
}
