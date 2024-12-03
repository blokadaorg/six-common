import 'package:common/common/widget/theme.dart';
import 'package:common/core/core.dart';
import 'package:common/platform/stage/stage.dart';
import 'package:common/v6/widget/tab/tab_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TabWidget extends StatefulWidget {
  const TabWidget({Key? key}) : super(key: key);

  @override
  State<TabWidget> createState() => _TabState();
}

class _TabState extends State<TabWidget> with Disposables {
  final _stage = DI.get<StageStore>();

  StageTab _active = StageTab.home;

  @override
  void initState() {
    super.initState();
    _stage.addOnValue(routeChanged, _updateRoute);
  }

  _updateRoute(StageRouteState route, Marker m) async {
    if (_stage.route.isTab(StageTab.home)) {
      _active = StageTab.home;
    } else if (_stage.route.isTab(StageTab.activity)) {
      _active = StageTab.activity;
    } else if (_stage.route.isTab(StageTab.advanced)) {
      _active = StageTab.advanced;
    } else if (_stage.route.isTab(StageTab.settings)) {
      _active = StageTab.settings;
    }

    rebuild(null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.bgColorCard,
        boxShadow: [
          BoxShadow(
            color: context.theme.shadow,
            spreadRadius: 0,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 18, right: 18, bottom: 32, top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TabItem(
                icon: Icons.shield_outlined,
                title: "main tab home".i18n,
                active: _active == StageTab.home,
                onTap: () {
                  _stage.setRoute("home", Markers.userTap);
                }),
            TabItem(
                icon: CupertinoIcons.chart_bar,
                title: "main tab activity".i18n,
                active: _active == StageTab.activity,
                onTap: () {
                  _stage.setRoute("activity", Markers.userTap);
                }),
            TabItem(
                icon: CupertinoIcons.cube_box,
                title: "main tab advanced".i18n,
                active: _active == StageTab.advanced,
                onTap: () {
                  _stage.setRoute("advanced", Markers.userTap);
                }),
            TabItem(
                icon: CupertinoIcons.settings,
                title: "main tab settings".i18n,
                active: _active == StageTab.settings,
                onTap: () {
                  _stage.setRoute("settings", Markers.userTap);
                }),
          ],
        ),
      ),
    );
  }
}
