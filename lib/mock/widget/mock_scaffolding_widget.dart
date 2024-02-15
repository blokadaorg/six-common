import 'package:common/util/config.dart';
import 'package:flutter/material.dart';

import '../../common/defaults/filter_decor_defaults.dart';
import '../../common/model.dart';
import '../../common/widget.dart';

class MockScaffoldingWidget extends StatelessWidget {
  MockScaffoldingWidget({Key? key}) : super(key: key);

  late final _pages = <Map<String, Widget Function(BuildContext)>>[
    {"": _buildHome},
    {"Filter components": _buildFilterComponents},
    {"Filters": _buildFilters},
  ];

  final _ctrl = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff4ae5f6),
              Color(0xff3c8cff),
              Color(0xff3c8cff),
            ],
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.transparent,
                Color(0xffe450cd),
                Color(0xffe450cd),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  context.theme.bgColorHome1.withOpacity(0.4),
                  context.theme.bgColorHome2,
                  context.theme.bgColorHome2,
                  context.theme.bgColorHome2,
                ],
              ),
            ),
            child: Stack(
              children: [
                PageView(
                  controller: _ctrl,
                  scrollDirection: Axis.horizontal,
                  children: _buildPages(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    return SizedBox(
      height: 100,
      child: MaterialButton(
        onPressed: () => _ctrl.animateToPage(0,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut),
        child: const Text("< go home"),
      ),
    );
  }

  List<Widget> _buildPages(BuildContext context) {
    return _pages.map((e) {
      return e.entries.first.value(context);
    }).toList();
  }

  Widget _buildHome(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _pages.map((e) {
          return MaterialButton(
              onPressed: () {
                _ctrl.animateToPage(
                  _pages.indexOf(e),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(e.entries.first.key));
        }).toList());
  }

  Widget _buildFilterComponents(BuildContext context) {
    return Column(
      children: [
        _buildBack(context),
        _buildTwoLetterIcon(context, "hello", false),
        _buildTwoLetterIcon(context, "wworld", false),
        _buildTwoLetterIcon(context, "lol", true),
        _buildTwoLetterIcon(context, "ad", true),
        _buildFilterOption(context),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    return ListView(
      children: [
        _buildBack(context),
        _buildFilter(context, 0, color: const Color(0xFFA9CCFE)),
        _buildFilter(context, 1),
        _buildFilter(context, 2, color: const Color(0xFFF4B1C6)),
        _buildFilter(context, 3, color: const Color(0XFFFDB39C)),
        _buildFilter(context, 4),
        _buildFilter(context, 5),
        _buildFilter(context, 6),
      ],
    );
  }

  Widget _buildFilter(BuildContext context, int index, {Color? color}) {
    final filter = getKnownFilters(cfg.act)[index];
    final texts = filterDecorDefaults
        .firstWhere((it) => it.filterName == filter.filterName);
    return FilterWidget(filter: filter, texts: texts, bgColor: color);
  }

  Widget _buildTwoLetterIcon(BuildContext context, String name, bool big) {
    return TwoLetterIconWidget(name: name, big: big);
  }

  Widget _buildFilterOption(BuildContext context) {
    final filter = getKnownFilters(cfg.act)[0];
    return FilterOptionWidget(option: filter.options.first, selections: []);
  }
}
