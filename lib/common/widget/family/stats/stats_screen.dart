import 'package:common/service/I18nService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:relative_scale/relative_scale.dart';
import 'package:vistraced/via.dart';

import '../../../../stage/channel.pg.dart';
import '../../../../ui/stats/column_chart.dart';
import '../../../model.dart';
import '../../../widget.dart';
import 'radial_segment.dart';
import 'totalcounter.dart';

part 'stats_screen.g.dart';

class StatsScreen extends StatefulWidget {
  final FamilyDevice device;

  const StatsScreen({Key? key, required this.device}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _$StatsScreenState();
}

@Injected(onlyVia: true, immediate: true)
class StatsScreenState extends State<StatsScreen> with ViaTools<StatsScreen> {
  late final _stats = Via.as<UiStats>()..also(rebuild);
  late final _modal = Via.as<StageModal?>()..also(rebuild);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: context.theme.bgColor,
        child: Stack(
          children: [
            RelativeBuilder(builder: (context, height, width, sy, sx) {
              return Column(
                children: [
                  const SizedBox(height: 42),
                  BackEditHeaderWidget(
                    name: widget.device.deviceDisplayName,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 16, right: 8),
                    child: Row(
                      children: [
                        Text("Activity",
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                      ],
                    ),
                  ),
                  Text("Activity screen TBD")
                  // Padding(
                  //   padding: const EdgeInsets.all(12.0),
                  //   child: MiniCard(
                  //     child: Column(
                  //       children: [
                  //         MiniCardHeader(
                  //           text: "stats header day".i18n,
                  //           icon: Icons.timelapse,
                  //           color: context.theme.textSecondary,
                  //         ),
                  //         const SizedBox(height: 4),
                  //         RadialSegment(stats: _stats.now),
                  //         const SizedBox(height: 16),
                  //         const Divider(),
                  //         ColumnChart(stats: _stats.now),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(12.0),
                  //   child: TotalCounter(stats: _stats.now),
                  // ),
                  // const Spacer(),
                  // SizedBox(height: sy(60)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
