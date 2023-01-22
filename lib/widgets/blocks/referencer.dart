import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

class ReferencerBlock<V> extends StatefulWidget {
  final Anxeb.Scope scope;
  final Anxeb.Referencer<V> referencer;
  final Anxeb.ReferenceItemWidget<V> itemWidget;
  final Anxeb.ReferenceHeaderWidget<V> headerWidget;
  final Anxeb.ReferenceCreateWidget<V> createWidget;
  final Anxeb.ReferenceEmptyWidget<V> emptyWidget;
  final EdgeInsets padding;

  ReferencerBlock({
    @required this.scope,
    this.referencer,
    this.itemWidget,
    this.headerWidget,
    this.emptyWidget,
    this.createWidget,
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

  List<Widget> _getNewButton(page) {
    if (widget.createWidget != null) {
      return [
        Container(
          margin: EdgeInsets.only(top: 14, bottom: 13),
          child: DottedLine(
            direction: Axis.horizontal,
            lineLength: double.infinity,
            lineThickness: 1,
            dashLength: 2,
            dashColor: widget.scope.application.settings.colors.primary,
            dashRadius: 0.0,
            dashGapLength: 4.0,
            dashGapColor: Colors.transparent,
          ),
        ),
        widget.createWidget(page),
      ];
    }
    return [];
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
                    child: $page.items.isEmpty == true
                        ? widget.emptyWidget?.call($page)
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...$page.items.map(($item) => widget.itemWidget($page, $item)).toList(),
                                ..._getNewButton($page),
                              ],
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
