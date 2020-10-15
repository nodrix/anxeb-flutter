import 'package:flutter/material.dart';
import 'dart:async';

class Slide {
  final ImageProvider image;
  final double zoomFrom;
  final Offset pushFrom;
  final Offset pushTo;
  final double scale;
  int index = 0;
  SliderOptions options;

  Slide({
    this.image,
    this.zoomFrom,
    this.scale,
    this.pushFrom,
    this.pushTo,
  });
}

class SliderOptions {
  final Duration fadeinDuration;
  final Duration fadeoutDuration;
  final Duration transformDuration;
  final Duration transitionDuration;
  final double scale;
  int index = 0;

  SliderOptions({
    this.fadeinDuration,
    this.fadeoutDuration,
    this.transformDuration,
    this.transitionDuration,
    this.scale,
  });
}

class SliderContainer extends StatefulWidget {
  SliderContainer({
    this.body,
    this.slides,
    this.gradient,
    this.options,
    this.image,
  })
      : assert(slides != null),
        super() {
    for (var i = 0; i < this.slides.length; i++) {
      this.slides[i].index = i;
      this.slides[i].options = this.options ?? SliderOptions();
    }
  }

  final Widget Function() body;
  final List<Slide> slides;
  final Gradient gradient;
  final SliderOptions options;
  final ImageProvider image;

  @override
  _SliderContainerState createState() => _SliderContainerState(body: this.body, gradient: this.gradient, slides: this.slides);
}

class _Slide extends StatefulWidget {
  final Slide definition;
  final bool visible;

  _Slide(this.definition, {this.visible});

  @override
  _SlideState createState() => _SlideState(this.definition);
}

class _SlideState extends State<_Slide> with TickerProviderStateMixin {
  AnimationController _opacityController;
  Animation<double> _opacityAnimation;
  AnimationController _scaleController;
  Animation<double> _scaleAnimation;
  AnimationController _positionController;
  Animation<Offset> _positionAnimation;
  bool _isVisible = false;

  _SlideState(Slide definition) {
    _opacityController = AnimationController(
      duration: definition.options.fadeinDuration ?? Duration(milliseconds: 400),
      vsync: this,
      value: 0,
      lowerBound: 0,
      upperBound: 1,
      reverseDuration: definition.options.fadeoutDuration ?? Duration(milliseconds: 600),
    );

    _opacityController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.dismissed) {
        _scaleController.reverse();
        _positionController.reverse();
      }
    });

    _opacityAnimation = CurvedAnimation(
      parent: _opacityController,
      curve: Curves.linear,
    );

    _scaleController = AnimationController(
      duration: definition.options.transformDuration ?? Duration(milliseconds: 4000),
      vsync: this,
      value: definition.zoomFrom ?? 0.8,
      lowerBound: definition.zoomFrom ?? 0.8,
      upperBound: 1,
      reverseDuration: Duration.zero,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.linear,
    );

    _positionController = AnimationController(
      duration: definition.options.transformDuration ?? Duration(milliseconds: 4000),
      vsync: this,
      value: 0,
      lowerBound: 0,
      upperBound: 1,
      reverseDuration: Duration.zero,
    );

    _positionAnimation = Tween<Offset>(begin: definition.pushFrom ?? Offset(0, 0), end: definition.pushTo ?? Offset(0, 0)).animate(_positionController);

    _opacityController.addListener(() {
      setState(() {});
    });

    _positionAnimation.addListener(() {
      setState(() {});
    });

    _scaleAnimation.addListener(() {
      setState(() {});
    });
  }

  initState() {
    super.initState();
  }

  @override
  dispose() {
    _opacityController.dispose();
    _scaleController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  double get _scale {
    return widget.definition.scale ?? widget.definition.options.scale ?? 1;
  }

  double get _scaleSubstract {
    if (_scale < 0) {
      return 2;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isVisible != this.widget.visible) {
      if (this.widget.visible == true) {
        _scaleController.forward();
        _positionController.forward();
        _opacityController.forward();
      } else {
        _opacityController.reverse();
      }
    }

    _isVisible = this.widget.visible;

    return Transform.scale(
      scale: (_scaleAnimation.value - _scaleSubstract) * _scale,
      child: OverflowBox(
        minWidth: 0,
        minHeight: 0,
        maxWidth: double.infinity,
        child: SlideTransition(
          position: _positionAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Image(
              image: this.widget.definition.image,
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderContainerState extends State<SliderContainer> {
  final Widget Function() body;
  final Gradient gradient;
  final List<Slide> slides;

  _SliderContainerState({this.body, this.gradient, this.slides}) : assert(slides != null);
  int _currentIndex = 0;

  void _nextSlide() {
    if (mounted) {
      setState(() {
        _currentIndex++;
        if (_currentIndex >= slides.length) {
          _currentIndex = 0;
        } else if (_currentIndex < 0) {
          _currentIndex = slides.length - 1;
        }
      });
    }
  }

  @override
  initState() {
    super.initState();
    Timer.periodic(widget.options.transitionDuration ?? Duration(milliseconds: 2000), (timer) {
      _nextSlide();
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;

    return Stack(
      children: <Widget>[
        Stack(
            children: widget.slides.map((options) {
              return _Slide(
                options,
                visible: options.index == _currentIndex,
              );
            }).toList()),
        gradient != null
            ? Container(
          decoration: BoxDecoration(gradient: gradient),
        )
            : Container(),
        widget.image != null ? Container(
          child: Image(
            image: widget.image,
            fit: BoxFit.fill,
            width: size.width,
            height: size.height,
            alignment: Alignment.topCenter,
          ),
        ) : Container(),
        body()
      ],
    );
  }
}
