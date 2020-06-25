import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';

class HeaderPart extends StatefulWidget implements PreferredSizeWidget {
  final Scope scope;
  final Size preferredSize;
  final List<Widget> actions;
  final Brightness brightness;
  final VoidCallback dismiss;
  final VoidCallback back;
  final Widget leading;

  HeaderPart({
    this.scope,
    this.actions,
    this.brightness,
    this.dismiss,
    this.back,
    this.leading,
  }) : preferredSize = Size.fromHeight(kToolbarHeight);

  @override
  _HeaderPartState createState() => _HeaderPartState();
}

class _HeaderPartState extends State<HeaderPart> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.scope.view.title ?? widget.scope.application.title),
      automaticallyImplyLeading: (widget.back == null && widget.dismiss == null && widget.leading == null) ? true : false,
      leading: widget.leading ?? (widget.back != null ? BackButton(onPressed: widget.back) : (widget.dismiss != null ? CloseButton(onPressed: widget.dismiss) : null)),
      brightness: widget.brightness ?? Brightness.dark,
      backgroundColor: widget.scope.application.settings.colors.primary,
      actions: widget.actions,
    );
  }
}
