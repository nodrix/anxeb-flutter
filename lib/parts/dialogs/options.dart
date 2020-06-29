import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/misc/key_value.dart';
import 'package:anxeb_flutter/widgets/buttons/text.dart';
import 'package:flutter/material.dart' hide Dialog;

class OptionsDialog extends ScopeDialog {
  final String title;
  final IconData icon;
  final List<KeyValue> options;
  final String selectedValue;

  OptionsDialog(Scope scope, {this.title, this.icon, this.options, this.selectedValue})
      : assert(title != null),
        super(scope) {
    super.dismissible = true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
      contentPadding: EdgeInsets.only(bottom: 20, left: 24, right: 24, top: 5),
      contentTextStyle: TextStyle(fontSize: title != null ? 16.4 : 20, color: scope.application.settings.colors.text, fontWeight: FontWeight.w400),
      title: icon != null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(right: 7),
                    //margin: EdgeInsets.only(right: 12),
                    /*decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 1.0, color: scope.application.settings.colors.separator),
                      ),
                    ),*/
                    child: Icon(
                      icon,
                      size: 29,
                      //color: scope.application.settings.colors.secudary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.left,
                      //style: TextStyle(color: scope.application.settings.colors.secudary,),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: EdgeInsets.only(bottom: 10),
              child: new Text(
                title ?? scope.view.title,
                textAlign: TextAlign.center,
              ),
            ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: TextButton.createOptions(
          context,
          options,
          selectedValue: selectedValue,
        ),
      ),
    );
  }
}
