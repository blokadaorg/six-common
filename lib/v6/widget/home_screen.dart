import 'package:common/core/core.dart';
import 'package:common/platform/stage/stage.dart';
import 'package:common/v6/widget/home/home_section.dart';
import 'package:common/v6/widget/home/stats/stats_section.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

class V6HomeScreen extends StatefulWidget {
  const V6HomeScreen({Key? key}) : super(key: key);

  @override
  State<V6HomeScreen> createState() => _V6HomeScreenState();
}

const pathHomeStats = "home/stats";

class _V6HomeScreenState extends State<V6HomeScreen> with Logging {
  final _stage = DI.get<StageStore>();

  final _pageCtrl = PageController(initialPage: 0);
  final _duration = const Duration(milliseconds: 800);
  final _curve = Curves.easeInOut;

  final _screenCtrl = PageController(initialPage: 0);

  var _path = "home";

  @override
  void initState() {
    super.initState();

    _pageCtrl.addListener(() {
      if (_pageCtrl.page == 1 && _path != pathHomeStats) {
        _path = pathHomeStats;

        log(Markers.userTap).trace("scrolledToStats", (m) async {
          await _stage.setRoute(_path, m);
        });
      } else if (_pageCtrl.page == 0 && _path != "home") {
        _path = "home";

        log(Markers.userTap).trace("scrolledToHome", (m) async {
          await _stage.setRoute(_path, m);
        });
      }
    });

    autorun((_) {
      final path = _stage.route.route.path;
      if (path == _path) return;
      _path = path;

      setState(() {
        if (path == pathHomeStats) {
          _animateToPage(1);
        } else if (_stage.route.isTab(StageTab.home) &&
            _stage.route.isMainRoute()) {
          _screenCtrl.jumpToPage(0);
          _animateToPage(0);
        } else if (_stage.route.isTab(StageTab.activity)) {
          _screenCtrl.jumpToPage(1);
        } else if (_stage.route.isTab(StageTab.advanced)) {
          _screenCtrl.jumpToPage(2);
        }
      });
    });
  }

  _animateToPage(int page) {
    _pageCtrl.animateToPage(page, duration: _duration, curve: _curve);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _screenCtrl,
            scrollDirection: Axis.horizontal,
            children: [
              // Home screen
              PageView(
                controller: _pageCtrl,
                scrollDirection: Axis.vertical,
                children: _getPages(),
              ),
              // Journal screen
              Text("Journal"),
              Text("Packs"),
              Text("Settings"),
            ],
          ),
          Column(
            children: [
              Spacer(),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _stage.setRoute("home", Markers.userTap),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Home"),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _stage.setRoute("activity", Markers.userTap),
                    child: Text("Activity"),
                  ),
                  GestureDetector(
                    onTap: () => _stage.setRoute("advanced", Markers.userTap),
                    child: Text("Advanced"),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  _getPages() {
    return <Widget>[
      V6HomeSection(),
      V6StatsSection(
          key: UniqueKey(), autoRefresh: true, controller: ScrollController()),
    ];
  }
}
