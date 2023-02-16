import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/widgets/buttons/text.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart' hide Dialog, TextButton;
import '../../middleware/application.dart';
import '../../middleware/tabs.dart';

class FormDialog<V, A extends Application> extends ScopeDialog<V> {
  final V model;
  final String title;
  final double width;
  final double height;
  final String subtitle;
  final IconData icon;
  final EdgeInsets headerPadding;
  final EdgeInsets contentPadding;
  final EdgeInsets footerPadding;
  final EdgeInsets insetPadding;
  final BorderRadius borderRadius;
  final MainAxisAlignment buttonAlignment;

  Radius _cornerRadius;
  FormScope<A> _scope;
  Color _headerFillColor;
  Color _footerFillColor;
  EdgeInsets _headerPadding;

  FormDialog(Scope scope, {
    @required this.model,
    @required this.title,
    @required this.width,
    this.height,
    this.subtitle,
    this.icon,
    this.headerPadding,
    this.contentPadding,
    this.footerPadding,
    this.insetPadding,
    this.borderRadius,
    this.buttonAlignment,
    bool dismissible,
    Key key,
  }) : super(scope) {
    super.dismissible = dismissible != null ? dismissible : (this.buttons == null);
    _cornerRadius = Radius.circular(scope.application.settings.dialogs.dialogRadius ?? 20.0);
  }

  @protected
  void init(FormScope<A> scope) {}

  @protected
  Widget body(FormScope<A> scope) => null;

  @protected
  List<TabItem> tabs(FormScope<A> scope) => [];

  @protected
  List<FormButton> buttons(FormScope<A> scope) => [];

  @override
  Widget build(BuildContext context) {
    final GlobalKey dialogKey = GlobalKey();
    return StatefulBuilder(
      key: dialogKey,
      builder: (context, setState) {
        final mustInit = _scope == null;
        _scope = _scope ?? FormScope<A>(context, parent: scope, setState: setState, key: dialogKey);
        if (mustInit) {
          init(_scope);
        }

        final $content = _getTabsWidget(context) ?? _getBodyWidget(context) ?? Container();
        final $header = _getDialogHeader(context);

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.all(Radius.circular(scope.application.settings.dialogs.dialogRadius ?? 20.0))),
          contentPadding: EdgeInsets.zero,
          buttonPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          insetPadding: insetPadding ?? EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          contentTextStyle: TextStyle(fontSize: title != null ? 16.4 : 20, color: scope.application.settings.colors.text, fontWeight: FontWeight.w400),
          title: $header,
          content: $content,
        );
      },
    );
  }

  Widget _getTabsWidget(BuildContext context) {
    final $tabs = tabs?.call(_scope);
    if ($tabs == null || $tabs.isEmpty == true) {
      return null;
    }
    _headerFillColor = scope.application.settings.dialogs.headerColor ?? Color(0xfff0f0f0);
    _footerFillColor = scope.application.settings.dialogs.footerColor;
    _headerPadding = EdgeInsets.only(left: 18, top: 18, right: 18, bottom: 6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: width,
          height: height ?? 400,
          margin: EdgeInsets.only(bottom: 1),
          color: Colors.white,
          child: DefaultTabController(
            length: $tabs.length,
            child: Column(
              children: [
                Material(
                  color: _headerFillColor,
                  child: TabBar(
                    indicatorColor: scope.application.settings.colors.success,
                    indicatorPadding: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.zero,
                    tabs: $tabs
                        .map(($tab) =>
                        Tab(
                          child: Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  child: $tab.icon == null ? null : Icon($tab.icon(), color: scope.application.settings.colors.primary, size: 18),
                                  padding: $tab.icon == null ? null : EdgeInsets.only(right: 4, top: 2),
                                ),
                                Text(
                                  $tab.caption(),
                                  style: TextStyle(color: scope.application.settings.colors.primary, fontWeight: FontWeight.w400, fontSize: 14, height: 1.1),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.only(left: 18),
                          ),
                          height: 28,
                        ))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: contentPadding ?? EdgeInsets.only(left: 18, right: 18, top: 18),
                    child: TabBarView(
                      children: $tabs.map((e) => e.body()).toList(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        _getDialogFooter(context),
      ],
    );
  }

  Widget _getBodyWidget(BuildContext context) {
    final $body = body?.call(_scope);
    if ($body == null) {
      return null;
    }
    _headerFillColor = null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: width,
          height: height,
          margin: EdgeInsets.only(bottom: 1),
          color: Colors.white,
          child: Container(
            padding: contentPadding ?? EdgeInsets.only(left: 18, right: 18),
            child: $body,
          ),
        ),
        _getDialogFooter(context),
      ],
    );
  }

  Widget _getDialogFooter(BuildContext context) {
    final formButtons = buttons(_scope);

    return Container(
      decoration: BoxDecoration(
        color: _footerFillColor,
        borderRadius: BorderRadius.only(bottomLeft: _cornerRadius, bottomRight: _cornerRadius),
      ),
      padding: EdgeInsets.only(left: footerPadding?.left ?? 16, right: footerPadding?.right ?? 16),
      child: Container(
        padding: EdgeInsets.only(top: footerPadding?.top ?? 16, bottom: footerPadding?.bottom ?? 16),
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
              margin: EdgeInsets.only(left: formButtons.first == $button ? 0 : 4, right: formButtons.last == $button ? 0 : 4),
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

            return Row(
              children: [
                $button.leftDivisor == true
                    ? Container(
                  height: 32,
                  padding: EdgeInsets.only(right: 10),
                  child: DottedLine(
                    direction: Axis.vertical,
                    lineLength: double.infinity,
                    lineThickness: 1,
                    dashLength: 2,
                    dashColor: scope.application.settings.colors.primary,
                    dashRadius: 0.0,
                    dashGapLength: 4.0,
                    dashGapColor: Colors.transparent,
                  ),
                )
                    : Container(),
                Container(
                  child: button,
                  width: button.width,
                  padding: EdgeInsets.only(right: isLast ? 0 : 10),
                ),
                $button.rightDivisor == true
                    ? Container(
                  height: 32,
                  padding: EdgeInsets.only(right: 10),
                  child: DottedLine(
                    direction: Axis.vertical,
                    lineLength: double.infinity,
                    lineThickness: 1,
                    dashLength: 2,
                    dashColor: scope.application.settings.colors.primary,
                    dashRadius: 0.0,
                    dashGapLength: 4.0,
                    dashGapColor: Colors.transparent,
                  ),
                )
                    : Container(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _getDialogHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _headerFillColor,
        borderRadius: BorderRadius.only(topLeft: _cornerRadius, topRight: _cornerRadius),
      ),
      padding: headerPadding ?? _headerPadding ?? EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 18),
      child: Row(
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
              margin: EdgeInsets.only(right: 2, bottom: 6),
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
    );
  }

  bool get exists => model != null;

  @protected
  Future Function(FormScope<A> scope) get close => null;
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
  final bool visible;
  final IconData icon;
  final List<Widget> fields;
  final Widget child;

  FormRowContainer({
    @required this.scope,
    this.title,
    this.visible,
    this.icon,
    this.fields,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (visible == false) {
      return Container();
    }
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
        child != null
            ? child
            : Container(
          height: 64,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: fields ?? [],
          ),
        )
      ],
    );
  }
}
