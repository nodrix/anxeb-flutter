import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/widgets/buttons/text.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart' hide Dialog, TextButton;
import '../../middleware/application.dart';

class FormDialog<V> extends ScopeDialog<V> {
  final String subtitle;
  final V model;
  final IconData icon;
  final EdgeInsets contentPadding;
  final EdgeInsets insetPadding;
  final BorderRadius borderRadius;
  final String title;
  final MainAxisAlignment buttonAlignment;

  FormScope _scope;

  FormDialog(
    Scope scope, {
    @required this.title,
    this.subtitle,
    @required this.model,
    this.icon,
    this.contentPadding,
    this.insetPadding,
    this.borderRadius,
    this.buttonAlignment,
    bool dismissible,
    Key key,
  }) : super(scope) {
    super.dismissible = dismissible != null ? dismissible : (this.buttons == null);
  }

  @protected
  void init(FormScope scope) {}

  @protected
  Widget body(FormScope scope) => Container();

  @protected
  List<FormButton> buttons(FormScope scope) => [];

  @override
  Widget build(BuildContext context) {
    final GlobalKey dialogKey = GlobalKey();
    return StatefulBuilder(
      key: dialogKey,
      builder: (context, setState) {
        final mustInit = _scope == null;
        _scope = _scope ?? FormScope(context, parent: scope, setState: setState, key: dialogKey);
        if (mustInit) {
          init(_scope);
        }

        final formButtons = buttons(_scope);

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(scope.application.settings.dialogs.dialogRadius ?? 20.0))),
          contentPadding: contentPadding ?? EdgeInsets.only(bottom: 18, left: 18, right: 18, top: 0),
          titlePadding: EdgeInsets.all(18),
          insetPadding: insetPadding ?? EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          contentTextStyle: TextStyle(fontSize: title != null ? 16.4 : 20, color: scope.application.settings.colors.text, fontWeight: FontWeight.w400),
          title: Row(
            children: <Widget>[
              Container(
                padding: subtitle == null ? null : EdgeInsets.only(right: 7),
                margin: EdgeInsets.only(right: 12),
                decoration: subtitle == null
                    ? null
                    : BoxDecoration(
                        border: Border(
                          right: BorderSide(width: 1.0, color: scope.application.settings.colors.separator),
                        ),
                      ),
                child: Icon(
                  icon,
                  size: subtitle == null ? 34 : 46,
                  color: scope.application.settings.colors.primary,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 20, color: scope.application.settings.colors.primary, fontWeight: FontWeight.w500),
                    ),
                    subtitle != null
                        ? Container(
                            padding: EdgeInsets.only(left: 1),
                            child: Text(
                              subtitle.toUpperCase(),
                              style: TextStyle(fontSize: 12, color: scope.application.settings.colors.primary, fontWeight: FontWeight.w300),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              close != null
                  ? Material(
                      color: Colors.transparent,
                      child: Container(
                        margin: EdgeInsets.only(right: 2,bottom: 6),
                        child: InkWell(
                          onTap: () async {
                            final result = await close?.call(_scope);
                            if (result == false) {
                              Navigator.of(context).pop(null);
                            } else if (result == null) {
                              //ignore
                            } else {
                              Navigator.of(context).pop(result is V ? result : model);
                            }
                          },
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.close),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              body?.call(_scope) ?? Container(),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: buttonAlignment ?? MainAxisAlignment.end,
                  children: formButtons.where(($button) => $button.visible != false).map(($button) {
                    var button = TextButton(
                      caption: $button.caption,
                      padding: EdgeInsets.only(left: 14, right: $button.icon != null ? 18 : 14, top: 6, bottom: 6),
                      radius: scope.application.settings.dialogs.buttonRadius,
                      icon: $button.icon,
                      swapIcon: $button.swapIcon,
                      color: $button.fillColor ?? scope.application.settings.colors.primary,
                      textColor: $button.textColor ?? Colors.white,
                      margin: EdgeInsets.only(top: 10, left: formButtons.first == $button ? 0 : 4, right: formButtons.last == $button ? 0 : 4),
                      onPressed: () async {
                        final result = await $button?.onTap?.call(_scope);
                        if (result == false) {
                          Navigator.of(context).pop(null);
                        } else if (result == null) {
                          //ignore
                        } else {
                          Navigator.of(context).pop(result is V ? result : model);
                        }
                      },
                      type: ButtonType.primary,
                      size: ButtonSize.small,
                    );

                    var isLast = formButtons.last == $button;

                    return Container(
                      child: button,
                      width: button.width,
                      padding: EdgeInsets.only(right: isLast ? 0 : 10),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool get exists => model != null;

  @protected
  Future Function(FormScope scope) get close => null;
}

class FormScope<A extends Application> extends Scope implements IScope {
  GlobalKey _key;
  Scope parent;
  StateSetter _setState;

  FormScope(BuildContext context, {@required this.parent, @required StateSetter setState, @required GlobalKey key}) : super(context) {
    _setState = setState;
    _key = key;
  }

  @override
  A get application => parent.application as A;

  @override
  String get key => parent.key;

  @override
  String get title => parent.title;

  @override
  bool get mounted => _key?.currentState?.mounted;

  @override
  void rasterize([VoidCallback fn]) {
    _setState(fn ?? () {});
  }
}

class FormSpacer extends StatelessWidget {
  final bool column;

  FormSpacer({this.column});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: column == true ? 18 : 0,
      width: column != true ? 10 : 0,
    );
  }
}

class FormRowContainer extends StatelessWidget {
  final Scope scope;
  final String title;
  final IconData icon;
  final List<Widget> fields;

  FormRowContainer({
    @required this.scope,
    this.title,
    this.icon,
    @required this.fields,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        title != null
            ? Container(
                padding: EdgeInsets.only(top: 0, bottom: 3),
                margin: EdgeInsets.only(bottom: 8, top: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        icon != null ? Icon(icon, size: 12, color: scope.application.settings.colors.primary) : Container(),
                        Expanded(
                          child: Text(
                            title.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 6),
                      child: DottedLine(
                        direction: Axis.horizontal,
                        lineLength: double.infinity,
                        lineThickness: 1,
                        dashLength: 2,
                        dashColor: scope.application.settings.colors.primary,
                        dashRadius: 0.0,
                        dashGapLength: 4.0,
                        dashGapColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              )
            : Container(),
        Container(
          height: 64,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: fields,
          ),
        )
      ],
    );
  }
}
