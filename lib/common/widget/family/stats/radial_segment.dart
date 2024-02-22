import 'package:common/common/widget.dart';
import 'package:common/service/I18nService.dart';
import 'package:countup/countup.dart';
import 'package:flutter/material.dart';
import 'package:vistraced/via.dart';

import '../../../../ui/stats/radial_chart.dart';
import '../../../model.dart';

class RadialSegment extends StatefulWidget {
  final UiStats stats;

  const RadialSegment({Key? key, required this.stats}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RadialSegmentState();
}

class RadialSegmentState extends State<RadialSegment> {
  var blocked = 0.0;
  var allowed = 0.0;
  var total = 0.0;
  var lastBlocked = 0.0;
  var lastAllowed = 0.0;
  var lastTotal = 0.0;

  _calculate() {
    lastAllowed = allowed;
    lastBlocked = blocked;
    lastTotal = total;
    allowed = widget.stats.dayAllowed.toDouble();
    blocked = widget.stats.dayBlocked.toDouble();
    total = widget.stats.dayTotal.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    _calculate();
    return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("stats label blocked".i18n,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Color(0xffff3b30),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                    Countup(
                      begin: lastBlocked,
                      end: blocked,
                      duration: const Duration(seconds: 1),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: SizedBox(
                  height: 44,
                  child: VerticalDivider(
                    color: context.theme.divider,
                    thickness: 1.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("stats label allowed".i18n,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Color(0xff33c75a),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        )),
                    Countup(
                      begin: lastAllowed,
                      end: allowed,
                      duration: const Duration(seconds: 1),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 96,
            height: 96,
            child: RadialChart(stats: widget.stats),
          ),
        ]);
  }
}
