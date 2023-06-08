import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/widgets/buttons/text.dart';
import 'package:flutter/material.dart' hide Dialog, TextButton;

class MultiOptionsDialog<V> extends ScopeDialog {
  final String title;
  final IconData icon;
  final List<DialogButton<V>> options;
  final List<V> selectedValues;
  final List<DialogButton> buttons;

  MultiOptionsDialog(
      Scope scope, {
        this.title,
        this.icon,
        this.options,
        this.selectedValues,
        this.buttons,
      })  : assert(title != null),
        super(scope) {
    super.dismissible = true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(scope.application.settings.dialogs.dialogRadius ?? 20.0))),
      contentPadding: EdgeInsets.only(bottom: 20, left: 24, right: 24, top: 5),
      contentTextStyle: TextStyle(
          fontSize: title != null ? 16.4 : 20,
          color: scope.application.settings.colors.text,
          fontWeight: FontWeight.w400),
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
      content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ...TextButton.createMultiOptions<V>(
                context,
                options,
                selectedValues: selectedValues,
                onChanged: (DialogButton<V> option, newValue) {
                  setState(() {
                    newValue ? selectedValues?.add(option.value) : selectedValues?.remove(option.value);
                  });
                },
              ),
              buttons != null
                  ? Container(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: TextButton.createList(context, buttons, settings: scope.application.settings),
                ),
              )
                  : Container(),
            ],
          ),
        );
      }),
    );
  }
}