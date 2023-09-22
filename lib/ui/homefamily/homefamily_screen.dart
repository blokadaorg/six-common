import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:mobx/mobx.dart' as mobx;
import 'package:mobx/mobx.dart';
import 'package:relative_scale/relative_scale.dart';

import '../../app/app.dart';
import '../../app/channel.pg.dart';
import '../../lock/lock.dart';
import '../../stage/channel.pg.dart';
import '../../stage/stage.dart';
import '../../util/di.dart';
import '../../util/trace.dart';
import '../debug/commanddialog.dart';
import '../debug/debugoptions.dart';
import '../home/counter.dart';
import '../minicard/minicard.dart';
import '../theme.dart';
import 'device.dart';

class HomeFamilyScreen extends StatefulWidget {
  HomeFamilyScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeFamilyScreenState();
  }
}

class HomeFamilyScreenState extends State<HomeFamilyScreen>
    with TickerProviderStateMixin, Traceable, TraceOrigin {
  final _app = dep<AppStore>();
  final _stage = dep<StageStore>();
  final _lock = dep<LockStore>();

  bool showDebug = false;
  bool hasPin = false;
  bool working = false;

  late AnimationController controller;
  late AnimationController controllerOrange;

  var counter = 0;

  Future<void> onRouteChanged(Trace parentTrace, StageRouteState route) async {
    if (!route.isForeground()) return;
    if (!route.isTab(StageTab.home)) return;

    if (!route.isBecameModal(StageModal.debug)) return;

    return await traceWith(parentTrace, "showDebug", (trace) async {
      // On purpose without await
      trace.addEvent("counter: ${counter++}");
      _showDebugDialog(context).then((_) {
        _stage.modalDismissed(trace);
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _stage.addOnValue(routeChanged, onRouteChanged);

    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    controllerOrange =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    autorun((_) {
      final status = _app.status;
      if (status.isWorking()) {
        controller.reverse();
        controllerOrange.reverse();
      } else if (status == AppStatus.activatedPlus) {
        controllerOrange.forward();
        controller.reverse();
      } else if (status == AppStatus.activatedCloud) {
        controller.forward();
        controllerOrange.reverse();
      } else {
        controller.reverse();
        controllerOrange.reverse();
      }

      setState(() {
        hasPin = _lock.hasPin;
        working = _app.status.isWorking() || !_stage.isReady;
      });
    });
  }

  @override
  void dispose() {
    _stage.removeOnValue(routeChanged, onRouteChanged);
    controller.dispose();
    controllerOrange.dispose();
    super.dispose();
  }

  _handleCtaTap() {
    return () {
      traceAs("tappedCta", (trace) async {
        await _stage.showModal(trace, StageModal.payment);
      });
    };
  }

  _handleLockTap() {
    return () {
      traceAs("tappedLock", (trace) async {
        await _stage.setRoute(trace, StageKnownRoute.homeOverlayLock.path);
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BlokadaTheme>()!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.bgColorHome3,
            theme.bgColorHome2,
            theme.bgColorHome1,
            theme.bgColor,
            theme.bgColor,
          ],
        ),
      ),
      child: AbsorbPointer(
        absorbing: working,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Stack(
            children: [
              RelativeBuilder(builder: (context, height, width, sy, sx) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onLongPress: () {
                        traceAs("tappedShowDebug", (trace) async {
                          await _stage.showModal(trace, StageModal.debug);
                        });
                      },
                      onHorizontalDragEnd: (_) {
                        _showCommandDialog(context);
                      },
                      child: Image.asset(
                        "assets/images/blokada_logo.png",
                        width: 200,
                        height: 128,
                        fit: BoxFit.scaleDown,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: HomeDevice(
                        deviceName: "Karolinho",
                        color: Colors.pink,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: HomeDevice(
                        deviceName: "Little Johnny",
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MiniCard(
                              onTap: _handleCtaTap(),
                              color: theme.plus,
                              child: SizedBox(
                                height: 32,
                                child: Center(child: Text("Add device")),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MiniCard(
                              onTap: _handleLockTap(),
                              child: SizedBox(
                                height: 32,
                                width: 32,
                                child: Icon(Icons.lock),
                              )),
                        )
                      ],
                    ),
                    SizedBox(height: sy(60)),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDebugDialog(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return DebugOptions();
        });
  }

  Future<void> _showCommandDialog(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return const CommandDialog();
        });
  }
}