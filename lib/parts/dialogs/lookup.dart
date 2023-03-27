import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart' hide Dialog, TextButton;
import 'package:flutter_translate/flutter_translate.dart';

import '../../middleware/field.dart';
import '../../middleware/form.dart';
import '../../widgets/blocks/list_title.dart';
import '../../widgets/buttons/text.dart';
import '../../widgets/fields/text.dart';

class LookupDialog<V> extends ScopeDialog {
  final String title;
  final IconData icon;
  final Future<List<V>> Function(String text) list;
  final String Function(V value) displayText;
  final String label;
  final FieldWidgetTheme theme;

  LookupDialog(
    Scope scope, {
    this.title,
    this.icon,
    this.list,
    this.displayText,
    this.label,
    this.theme,
  })  : assert(title != null),
        super(scope) {
    super.dismissible = true;
  }

  @override
  Widget build(BuildContext context) {
    var cancel = (BuildContext context) {
      Future.delayed(Duration(milliseconds: 0)).then((value) {
        scope.unfocus();
      });
      Navigator.of(context).pop(null);
    };

    List<DialogButton> buttons = [
      DialogButton(translate('anxeb.common.cancel'), null, onTap: (context) => cancel(context)),
      //DialogButton(translate('anxeb.common.accept'), null, onTap: (context) => accept()),
    ];

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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LookupListBlock<V>(
            scope: scope,
            list: list,
            displayText: displayText,
            label: label,
            theme: theme,
            onSelect: (V item) {
              Future.delayed(Duration(milliseconds: 0)).then((value) {
                scope.unfocus();
              });
              Navigator.of(context).pop(item);
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
              : Container()
        ],
      ),
    );
  }
}

class LookupListBlock<V> extends StatefulWidget {
  final Scope scope;
  final Future<List<V>> Function(String text) list;
  final String Function(V value) displayText;
  final String label;
  final FieldWidgetTheme theme;
  final Function(V item) onSelect;

  const LookupListBlock({
    @required this.scope,
    @required this.list,
    @required this.displayText,
    @required this.label,
    @required this.theme,
    @required this.onSelect,
  });

  @override
  State<LookupListBlock> createState() => _LookupListBlockState<V>();
}

class _LookupListBlockState<V> extends State<LookupListBlock<V>> {
  List<V> _items;
  final _formName = '_lookup_form';

  @override
  void initState() {
    form.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextInputField<String>(
          scope: widget.scope,
          name: 'lookup',
          group: _formName,
          label: widget.label,
          theme: widget.theme,
          action: TextInputAction.done,
          margin: const EdgeInsets.only(bottom: 10),
          type: TextInputFieldType.text,
          autofocus: true,
          selected: true,
          focusNext: false,
          onChanged: (newValue) {},
          onActionSubmit: (text) async {
            _items = await widget.list(text);
            form.focus('lookup', force: true);
            setState(() {});
          },
        ),
        Container(
          height: 200,
          width: 400,
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _items?.isNotEmpty == true
                    ? _items
                        .map((e) => ListTitleBlock(
                              scope: widget.scope,
                              iconTrail: Icons.chevron_right,
                              iconTrailScale: 0.4,
                              busy: false,
                              iconScale: 0.6,
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              iconColor: widget.scope.application.settings.colors.secudary,
                              title: widget.displayText(e),
                              onTap: () async {
                                widget.onSelect?.call(e);
                              },
                              padding: const EdgeInsets.only(left: 12, top: 5, bottom: 5, right: 5),
                              borderRadius: BorderRadius.all(Radius.circular(widget.scope.application.settings.dialogs.buttonRadius)),
                            ))
                        .toList()
                    : []),
          ),
        ),
      ],
    );
  }

  FieldsForm get form => widget.scope.forms[_formName];
}
