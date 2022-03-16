import 'package:anxeb_flutter/anxeb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ReferencerBlock<V> extends StatefulWidget {
  final Scope scope;
  final Referencer<V> referencer;
  final ReferenceItemWidget<V> itemWidget;
  final ReferenceHeaderWidget<V> headerWidget;
  final EdgeInsets padding;

  ReferencerBlock({
    @required this.scope,
    this.referencer,
    this.itemWidget,
    this.headerWidget,
    this.padding,
  }) : assert(referencer != null);

  @override
  _ReferencerBlockState createState() => _ReferencerBlockState<V>();
}

class _ReferencerBlockState<V> extends State<ReferencerBlock<V>> {
  @override
  void initState() {
    widget.referencer.updater = () {
      if (mounted) {
        setState(() {});
      }
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      allowImplicitScrolling: true,
      pageSnapping: true,
      controller: widget.referencer.controller,
      onPageChanged: (index) {
        widget.referencer.currentPage = index;
      },
      children: widget.referencer.pages
          .map(
            ($page) => Container(
              padding: widget.padding,
              child: Column(
                children: <Widget>[
                  widget?.headerWidget?.call($page) ?? Container(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: $page.items.map(($item) => widget.itemWidget($page, $item)).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
