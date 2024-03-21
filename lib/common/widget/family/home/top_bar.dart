import 'dart:io';
import 'dart:ui';

import 'package:common/common/widget.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../util/async.dart';

class TopBar extends StatefulWidget {
  final bool alwaysShowTitle;
  final double height;
  final Widget? trailing;
  final bool sliding;

  const TopBar(
      {super.key,
      this.alwaysShowTitle = false,
      this.height = 100,
      this.sliding = false,
      this.trailing});

  @override
  State<StatefulWidget> createState() => TopBarState();
}

class TopBarState extends State<TopBar> with TickerProviderStateMixin {
  double _show = 0.0;
  bool _transitioning = false;
  bool _blurBackground = false;

  bool _showTitle = false;
  String _title = "";
  String _waitingTitle = "";

  String _back = "";
  String _waitingBack = "";

  bool? _playForward;

  late final _ctrlShow = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  );

  late final _showOffset =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: _ctrlShow,
    curve: Curves.linear,
  ));

  late final _ctrlBgOpacity = AnimationController(
    duration: const Duration(milliseconds: 50),
    vsync: this,
  );

  late final _bgOpacity =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: _ctrlBgOpacity,
    curve: Curves.easeInOut,
  ));

  late final _ctrlTitleOpacity = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );

  late final _titleOpacity =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: _ctrlTitleOpacity,
    curve: Curves.easeInOut,
  ));

  late final _ctrlWidgetsOpacity = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );

  late final _widgetsOpacity =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: _ctrlWidgetsOpacity,
    curve: Curves.easeInOut,
  ));

  late final _ctrlTextOffset = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  );

  late final _textOffset = TweenSequence([
    TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -0.8), weight: 1),
    TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 0.0), weight: 1),
  ]).animate(CurvedAnimation(
    parent: _ctrlTextOffset,
    curve: Curves.easeInOut,
  ));

  @override
  void initState() {
    super.initState();

    _ctrlTextOffset.addStatusListener((status) {
      if (status == AnimationStatus.forward ||
          status == AnimationStatus.reverse) {
        // Update text in the middle of the transition (when it's transparent)
        Future.delayed(_ctrlTextOffset.duration! * 0.5, () {
          _title = _waitingTitle;
          _back = _waitingBack;
          _ctrlTitleOpacity.forward();
          _ctrlWidgetsOpacity.forward();
        });
      } else if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _playForward = null;
        //_ctrlTextOffset.reset();
      }
    });

    _ctrlShow.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_ctrlShow.isAnimating) return;
          _transitioning = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _ctrlTitleOpacity.dispose();
    _ctrlWidgetsOpacity.dispose();
    _ctrlBgOpacity.dispose();
    _ctrlTextOffset.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TopBarController>(
      builder: (context, controller, child) {
        _show = widget.sliding ? controller.show : 1.0;
        if (_show == 1.0 && _ctrlShow.value == 0.0) {
          _ctrlShow.forward();
          //_ctrlTextOpacity.forward(from: 0.0);
          _transitioning = true;
        } else if (_show == 0.0 && _ctrlShow.value == 1.0) {
          _ctrlShow.reverse();
          //_ctrlTextOpacity.reverse(from: 0.0);
          _transitioning = true;
        } else if (!_transitioning) {
          _ctrlShow.value = _show;
          // _ctrlTextOpacity.value = _show / 2;
        }

        if (controller.blurBackground != _blurBackground) {
          _blurBackground = controller.blurBackground;
          if (_blurBackground) {
            _ctrlBgOpacity.forward();
          } else {
            _ctrlBgOpacity.reverse();
          }
        }

        if (controller.showTitle != _showTitle || widget.alwaysShowTitle) {
          _showTitle = controller.showTitle || widget.alwaysShowTitle;
          if (_title.isBlank) _title = controller.title;
          if (_showTitle) {
            _ctrlTitleOpacity.forward();
          } else {
            _ctrlTitleOpacity.reverse();
          }
        }

        if (controller.title != _title) {
          _playForward = controller.playForward;
          _waitingTitle = controller.title;
          _waitingBack = controller.back.lastOrNull ?? "";

          if (_playForward == true) {
            _ctrlTitleOpacity.reverse();
            _ctrlWidgetsOpacity.reverse();
            _ctrlTextOffset.forward(from: 0.0);
            _ctrlShow.forward();
          } else if (_playForward == false) {
            _ctrlTitleOpacity.reverse();
            _ctrlWidgetsOpacity.reverse();
            _ctrlTextOffset.value = 1.0;
            _ctrlTextOffset.reverse(from: 1.0);
          }
        }

        final width = MediaQuery.of(context).size.width;
        return AnimatedBuilder(
            animation: _showOffset,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                    widget.sliding ? width - width * _showOffset.value : 0, 0),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    AnimatedBuilder(
                        animation: _bgOpacity,
                        builder: (context, child) {
                          return Stack(
                            children: [
                              Container(
                                height: widget.height,
                                color: _bgOpacity.value == 1 &&
                                        _showOffset.value == 1.0
                                    ? Colors.transparent
                                    : controller.backgroundColor,
                              ),
                              Opacity(
                                opacity: _showOffset.value == 1.0
                                    ? _bgOpacity.value
                                    : 0.0,
                                child: Column(
                                  children: [
                                    ClipRect(
                                      child: SizedBox(
                                        height: widget.height,
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 25,
                                            sigmaY: 25,
                                          ),
                                          child: Container(
                                            color: context.theme.shadow
                                                .withOpacity(0.2),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 1,
                                      color: context.theme.divider
                                          .withOpacity(0.08),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _titleOpacity,
                            _widgetsOpacity,
                            _textOffset,
                          ]),
                          builder: (context, child) {
                            return Stack(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Transform.translate(
                                      offset:
                                          Offset(_textOffset.value * 100, 0),
                                      child: Opacity(
                                        opacity: _titleOpacity.value *
                                            (_showTitle ? 1.0 : 0.0),
                                        child: Text(_title,
                                            style: TextStyle(
                                                color:
                                                    context.theme.textPrimary,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                    // Other elements...
                                  ],
                                ),
                                Opacity(
                                  opacity: _widgetsOpacity.value *
                                      (_back.isNotBlank ? 1.0 : 0.0),
                                  child: Icon(Icons.arrow_back_ios,
                                      color: context.theme.family),
                                ),
                                Transform.translate(
                                  offset: Offset(
                                      20 + _textOffset.value * 100 * 0.3, 0),
                                  child: Opacity(
                                    opacity: _widgetsOpacity.value,
                                    child: Text(_back,
                                        style: TextStyle(
                                            color: context.theme.family,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400)),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (widget.trailing != null)
                                      Transform.translate(
                                        offset:
                                            //Offset(_textOffset.value * 100, 0),
                                            Offset(0, 0),
                                        child: Opacity(
                                          opacity: 1.0,
                                          child: widget.trailing,
                                        ),
                                      ),
                                    SizedBox(width: 8),
                                  ],
                                ),
                              ],
                            );
                          }),
                    ),
                  ],
                ),
              );
            });
      },
    );
  }
}

class TopBarController with ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  double show = 0.0;

  bool showTitle = false;
  String title = "Home";

  List<String> back = [];

  Color backgroundColor = const Color(0xFFF2F1F6);
  bool blurBackground = false;

  bool? playForward;

  void updateScrollPos(double pos) {
    if (pos >= 10 && !showTitle) {
      showTitle = true;
      notifyListeners();
    } else if (pos >= 11 && !blurBackground) {
      blurBackground = true;
      notifyListeners();
    } else if (pos < 11 && blurBackground) {
      blurBackground = false;
      notifyListeners();
    } else if (pos < 10 && showTitle) {
      showTitle = false;
      notifyListeners();
    }
  }

  void updateNavPos(double pos) {
    if (pos > show) {
      show = pos;
      notifyListeners();
    } else if (pos < show && back.length <= 1 && (show - pos) < 0.2) {
      // The delta condition is because "back" will be changed before the
      // animation is done so it was being interpreted incorrectly.
      show = pos;
      notifyListeners();
    }
  }

  void goNext(String title) {
    back.add(this.title);
    this.title = title;
    playForward = true;
    show = 1.0;
    notifyListeners();
  }

  void set(String title) {
    back.clear();
    this.title = title;
    playForward = true;
    show = 1.0;
    notifyListeners();
  }

  void goBack() {
    if (back.isEmpty) return;
    title = back.removeLast();
    playForward = false;
    notifyListeners();
  }
}

class TopBarObserver extends NavigatorObserver {
  final TopBarController controller;

  TopBarObserver({required this.controller});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    controller.goBack();
  }
}
