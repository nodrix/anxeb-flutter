import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/material.dart' hide Dialog;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../middleware/application.dart';

class SliderDialog<V> extends ScopeDialog {
  final List<SliderItem> slides;

  SliderDialog(Scope scope, {this.slides}) : super(scope) {
    super.dismissible = true;
  }

  @override
  Widget build(BuildContext context) {
    return _SliderBlock(
      scope: scope,
      context: context,
      slides: slides,
    );
  }
}

class _SliderBlock extends StatefulWidget {
  final Scope scope;
  final BuildContext context;
  final List<SliderItem> slides;

  _SliderBlock({this.scope, this.context, this.slides});

  @override
  _SliderBlockState createState() => _SliderBlockState();
}

class _SliderBlockState extends State<_SliderBlock> {
  int _index;
  double _width;

  @override
  void initState() {
    if (widget.slides.length > 0) {
      widget.slides.first.onOpened?.call();
    }

    _width = _width ?? widget.scope.window.available.width;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.all(Radius.circular(24));
    final controller = PageController(keepPage: true);

    final pages = widget.slides.map((e) {
      final fillColor = e.color ?? Colors.white;

      return Stack(
        children: [
          e.cover != null
              ? Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      colorFilter: ColorFilter.mode(fillColor.withOpacity(0.4), BlendMode.screen),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      image: e.cover.image,
                    ),
                  ),
                )
              : Container(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  fillColor.withOpacity(0.5),
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(0.5),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 30, bottom: 30, left: 7, right: 7),
                    width: _width * .6,
                    child: Text(
                      e.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              e.image != null
                  ? Container(
                      width: _width * .3,
                      height: _width * .3,
                      child: e.image,
                    )
                  : Container(),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(top: 20, left: 18, right: 18),
                  child: e.content?.call() ??
                      Text(
                        e.body ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, letterSpacing: -0.1),
                      ),
                ),
              ),
              e.action != null
                  ? Container(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: e.action,
                    )
                  : Container(),
              SizedBox(
                height: 60,
              )
            ],
          ),
        ],
      );
    }).toList();

    return Container(
      margin: EdgeInsets.only(bottom: 80, top: 40),
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: radius),
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        content: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Stack(
            children: [
              PageView(
                allowImplicitScrolling: true,
                pageSnapping: true,
                controller: controller,
                children: pages,
                onPageChanged: (index) {
                  setState(() {
                    _index = index;
                    widget.slides[_index].onOpened?.call();
                  });
                },
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isOnePage == true
                          ? Container(width: 45)
                          : Anxeb.IconButton(
                              padding: EdgeInsets.only(left: 12),
                              iconSize: 24,
                              fillColor: _isFirstPage ? Colors.white.withOpacity(0) : Colors.white.withOpacity(0.5),
                              innerColor: _isFirstPage ? application.settings.colors.primary.withOpacity(0.4) : application.settings.colors.primary,
                              size: 33,
                              icon: Icons.chevron_left,
                              action: () async {
                                if (!_isFirstPage) {
                                  controller.previousPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
                                }
                              },
                            ),
                      Expanded(
                        child: pages.length > 1
                            ? Container(
                                alignment: Alignment.center,
                                child: SmoothPageIndicator(
                                  controller: controller,
                                  count: pages.length,
                                  effect: WormEffect(
                                    dotHeight: 8,
                                    dotWidth: 8,
                                    activeDotColor: application.settings.colors.primary,
                                    dotColor: application.settings.colors.primary.withOpacity(0.3),
                                    type: WormType.normal,
                                  ),
                                ),
                              )
                            : Container(),
                      ),
                      Anxeb.IconButton(
                        padding: EdgeInsets.only(right: 12),
                        iconSize: 24,
                        fillColor: Colors.white.withOpacity(0.5),
                        innerColor: _isLastPage ? application.settings.colors.primary.withOpacity(0.5) : application.settings.colors.primary,
                        size: 33,
                        icon: _isLastPage ? Icons.check : Icons.chevron_right,
                        action: () async {
                          if (_isLastPage) {
                            Navigator.of(widget.context).pop();
                          } else {
                            controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
                          }
                        },
                      )
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isOnePage => widget.slides.length == 1;

  bool get _isLastPage => _isOnePage ? true : (_index ?? 0) >= widget.slides.length - 1;

  bool get _isFirstPage => _isOnePage ? true : (_index ?? 0) == 0;

  Application get application => widget.scope.application;
}

class SliderItem {
  final String title;
  final String body;
  final Widget Function() content;
  final Image cover;
  final Image image;
  final Color color;
  final Anxeb.TextButton action;
  final Function() onOpened;

  SliderItem({this.title, this.body, this.content, this.cover, this.image, this.color, this.action, this.onOpened});
}
