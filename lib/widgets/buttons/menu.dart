import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../middleware/application.dart';
import '../../page/scope.dart';
import '../blocks/menu.dart';

class MenuButton extends StatelessWidget {
  final PageScope<Application> scope;
  final String caption;
  final IconData icon;
  final bool visible;
  final Color color;
  final GestureTapCallback onTap;
  final EdgeInsets margin;
  final ContextMenu contextMenu;

  MenuButton({
    @required this.scope,
    this.caption,
    this.icon,
    this.visible,
    this.color,
    this.onTap,
    this.margin,
    this.contextMenu,
  });

  @override
  Widget build(BuildContext context) {
    if (visible == false) {
      return Container();
    }


    Widget button = Container(
      padding: EdgeInsets.only(left: icon != null ? 6 : 12, right: 12, top: 6, bottom: 6),
      child: Row(
        children: [
          icon != null
              ? Container(
            margin: EdgeInsets.only(right: 4),
            child: Icon(icon, color: color ?? scope.application.settings.colors.primary),
          )
              : Container(),
          Text(
            caption,
            style: TextStyle(
              fontSize: 15,
              letterSpacing: 0.15,
              fontWeight: FontWeight.w300,
              color: color ?? scope.application.settings.colors.primary,
            ),
          ),
        ],
      ),
    );

    if (contextMenu?.items?.isNotEmpty == true ) {
      return Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(scope.application.settings.dialogs.buttonRadius)),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(scope.application.settings.dialogs.buttonRadius)),
            child: ContextMenuBlock(
              scope: scope,
              offset: contextMenu.offset,
              child: button,
              items: contextMenu.items,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(scope.application.settings.dialogs.buttonRadius)),
        child: InkWell(
          onTap: onTap,
          enableFeedback: true,
          borderRadius: BorderRadius.all(Radius.circular(scope.application.settings.dialogs.buttonRadius)),
          child: button,
        ),
      ),
    );
  }
}

class MenuSearchButton extends StatefulWidget {
  final double width;
  final Color textColor;
  final double buttonRadius;
  final EdgeInsets margin;
  final String hintText;
  final Color hintTextColor;
  final TextStyle inputTextStyle;
  final TextInputType textInputType;
  final List<TextInputFormatter> inputFormatters;
  final Function onSaved;
  final Function onChanged;
  final Function onFieldSubmitted;
  final Function onEditingComplete;
  final Function onExpansionComplete;
  final Function onCollapseComplete;
  final Function(bool isOpen) onPressButton;
  final int speed;

  const MenuSearchButton({
    this.width,
    this.textColor,
    this.buttonRadius,
    this.margin,
    this.hintText,
    this.hintTextColor,
    this.inputTextStyle,
    this.textInputType = TextInputType.text,
    this.inputFormatters,
    this.onSaved,
    this.onChanged,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.onExpansionComplete,
    this.onCollapseComplete,
    this.onPressButton,
    this.speed,
    Key key,
  }) : super(key: key);

  @override
  _MenuSearchButtonState createState() => _MenuSearchButtonState();
}

class _MenuSearchButtonState extends State<MenuSearchButton> with SingleTickerProviderStateMixin {
  TextEditingController _textEditingController;
  AnimationController _animationController;
  FocusNode _focusNode;
  bool _animating = false;
  bool _active = false;

  final DecorationTween decorationTween = DecorationTween(
    begin: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(60),
    ),
    end: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(60),
    ),
  );

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted == true && _active == true) {
        if (!_focusNode.hasFocus) {
          setState(() {
            _toogle(state: false);
          });
        }
      }
    });

    _textEditingController = TextEditingController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: speed),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: Row(
        children: [
          AnimatedOpacity(
            opacity: _active ? 0 : 1,
            duration: Duration(milliseconds: speed),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _active ? null : () => _toogle(state: true),
                enableFeedback: false,
                focusColor: Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(widget.buttonRadius)),
                child: Container(
                  padding: EdgeInsets.only(left: 6, right: 12, top: 6, bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: _active ? 0 : 4),
                        child: Icon(Icons.search, color: widget.textColor),
                      ),
                      Text(
                        'Buscar',
                        style: TextStyle(
                          fontSize: 15,
                          letterSpacing: 0.15,
                          fontWeight: FontWeight.w300,
                          color: widget.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: _searchBarWidget(),
          ),
        ],
      ),
    );
  }

  Widget _searchBarWidget() {
    return Container(
      height: _active ? 36 : 10,
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: _animating ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: AnimatedContainer(
          duration: Duration(milliseconds: speed),
          height: 36,
          width: (!_active) ? 0 : (widget.width ?? 300),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: Duration(milliseconds: speed),
                right: 6,
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  opacity: _active ? 1 : 0,
                  duration: Duration(milliseconds: speed),
                  child: InkWell(
                    enableFeedback: false,
                    focusColor: Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(widget.buttonRadius)),
                    onTap: () {
                      _toogle(state: false);
                    },
                    child: Container(
                      height: 34,
                      alignment: Alignment.centerRight,
                      width: (MediaQuery.of(context).size.width) / 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.close,
                          color: widget.textColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: speed),
                left: 10,
                curve: Curves.easeOut,
                top: 11,
                child: AnimatedOpacity(
                  opacity: (!_active) ? 0 : 1,
                  duration: Duration(milliseconds: speed),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    width: (MediaQuery.of(context).size.width) / 3,
                    child: _textFormField(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toogle({bool state}) {
    if (state != null) {
      _active = !state;
    }
    _animating = true;
    widget.onPressButton?.call(!_active);
    setState(
      () {
        if (!_active) {
          _textEditingController.clear();
          _active = true;
          setState(() {
            FocusScope.of(context).requestFocus(_focusNode);
          });
          _animationController.forward().then((value) {
            setState(() {
              _animating = true;
            });
            widget.onExpansionComplete?.call();
          });
        } else {
          _active = false;
          setState(() {
            _unFocusKeyboard();
          });
          _animationController.reverse().then((value) {
            setState(() {
              _animating = false;
            });
            widget.onCollapseComplete?.call();
          });
        }
      },
    );
  }

  Widget _textFormField() {
    return TextFormField(
      controller: _textEditingController,
      inputFormatters: widget.inputFormatters,
      focusNode: _focusNode,
      cursorWidth: 2.0,
      textInputAction: TextInputAction.search,
      onFieldSubmitted: (String value) {
        setState(() {
          _active = true;
        });

        FocusScope.of(this.context).requestFocus(_focusNode);
        _textEditingController.selection = TextSelection(baseOffset: 0, extentOffset: _textEditingController.text.length);
        widget.onFieldSubmitted?.call(_textEditingController.text);
      },
      onEditingComplete: () {
        _unFocusKeyboard();
        setState(() {
          _active = false;
        });
        widget.onEditingComplete?.call();
      },
      keyboardType: widget.textInputType,
      onChanged: (var value) {
        widget.onChanged?.call(value);
      },
      onSaved: (var value) {
        widget.onSaved?.call(value);
      },
      style: widget.inputTextStyle ?? const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w300),
      cursorColor: Colors.black,
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        isDense: true,
        icon: Icon(Icons.search),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: 15,
          letterSpacing: 0.15,
          fontWeight: FontWeight.w300,
          color: widget.hintTextColor,
          height: 1.4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _unFocusKeyboard() {
    final FocusScopeNode currentFocusScope = FocusScope.of(context);
    if (!currentFocusScope.hasPrimaryFocus && currentFocusScope.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  int get speed => widget.speed ?? 200;
}
