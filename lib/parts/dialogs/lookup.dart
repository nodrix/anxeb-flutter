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
  final String initialLookup;
  final String Function(V value) subtitleText;
  final Widget Function(V item, Function(V item) select) itemWidget;
  final bool autofocus;
  final double width;
  final double maxHeight;
  final Future<V> Function() create;

  LookupDialog(
    Scope scope, {
    this.title,
    this.icon,
    this.list,
    this.displayText,
    this.label,
    this.theme,
    this.initialLookup,
    this.subtitleText,
    this.itemWidget,
    this.autofocus,
    this.width,
    this.maxHeight,
    this.create,
  })  : assert(title != null),
        super(scope) {
    super.dismissible = true;
  }

  bool _canCreate;

  @override
  Future<V> alternative() async {
    if (_canCreate == true) {
      return await create();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var cancel = (BuildContext context) async {
      Future.delayed(Duration(milliseconds: 0)).then((value) {
        scope.unfocus();
      });
      Navigator.of(context).pop(null);
    };

    List<DialogButton> buttons = [
      //TODO: translate('anxeb.common.add')
      if (create != null)
        DialogButton('Nuevo', null, icon: Icons.add, fillColor: scope.application.settings.colors.success, onTap: (context) async {
          Future.delayed(Duration(milliseconds: 0)).then((value) {
            scope.unfocus();
          });
          _canCreate = true;
          Navigator.of(context).pop(null);
        }),
      DialogButton(translate('anxeb.common.cancel'), null, onTap: (context) => cancel(context)),
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
      content: Container(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LookupListBlock<V>(
              scope: scope,
              list: list,
              displayText: displayText,
              subtitleText: subtitleText,
              label: label,
              theme: theme,
              initialLookup: initialLookup,
              itemWidget: itemWidget,
              autofocus: autofocus,
              maxHeight: maxHeight,
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
  final String Function(V value) subtitleText;
  final String initialLookup;
  final Widget Function(V item, Function(V item) select) itemWidget;
  final bool autofocus;
  final double maxHeight;

  const LookupListBlock({
    @required this.scope,
    @required this.list,
    @required this.displayText,
    @required this.label,
    @required this.theme,
    @required this.onSelect,
    this.subtitleText,
    this.initialLookup,
    this.itemWidget,
    this.autofocus,
    this.maxHeight,
  });

  @override
  State<LookupListBlock> createState() => _LookupListBlockState<V>();
}

class _LookupListBlockState<V> extends State<LookupListBlock<V>> {
  List<V> _items;
  final _formName = '_lookup_form';
  bool _busy;

  @override
  void initState() {
    form.clear();

    if (_items == null && widget.initialLookup != null) {
      setState(() {
        _busy = true;
      });
      try {
        widget.list(widget.initialLookup).then((value) {
          setState(() {
            _items = value;
          });
        });
        if (widget.autofocus != false) {
          form.focus('lookup', force: true);
        }
        setState(() {});
      } catch (err) {
        _items = null;
      } finally {
        setState(() {
          _busy = false;
        });
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var body = _busy == true
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.scope.application.settings.colors.primary),
                ),
              ),
            ],
          )
        : SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _items?.isNotEmpty == true
                    ? _items
                        .map((e) =>
                            widget.itemWidget?.call(e, widget.onSelect) ??
                            ListTitleBlock(
                              scope: widget.scope,
                              iconTrail: Icons.chevron_right,
                              iconTrailPadding: widget.subtitleText?.call(e)?.isNotEmpty == true ? const EdgeInsets.only(top: 10) : null,
                              iconTrailScale: 0.4,
                              busy: false,
                              iconScale: 0.6,
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              iconColor: widget.scope.application.settings.colors.secudary,
                              title: widget.displayText(e),
                              subtitle: widget.subtitleText?.call(e),
                              onTap: () async {
                                widget.onSelect?.call(e);
                              },
                              padding: EdgeInsets.only(left: 12, top: 5, bottom: widget.subtitleText != null ? 6 : 5, right: 5),
                              borderRadius: BorderRadius.all(Radius.circular(widget.scope.application.settings.dialogs.buttonRadius)),
                            ))
                        .toList()
                    : []),
          );

    return Container(
      height: widget.scope.window.available.height * .7,
      constraints: BoxConstraints(maxHeight: widget.maxHeight ?? 530),
      child: Column(
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
            autofocus: widget.autofocus ?? true,
            selected: widget.autofocus ?? true,
            onChanged: (newValue) {},
            onActionSubmit: (text) async {
              setState(() {
                _busy = true;
              });
              try {
                _items = await widget.list(text);
                if (widget.autofocus != false) {
                  form.focus('lookup', force: true);
                }
                setState(() {});
              } catch (err) {
                _items = null;
              } finally {
                setState(() {
                  _busy = false;
                });
              }
            },
          ),
          Expanded(
            child: body,
          ),
        ],
      ),
    );
  }

  FieldsForm get form => widget.scope.forms[_formName];
}
