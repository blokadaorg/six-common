import 'package:common/common/model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:relative_scale/relative_scale.dart';

import '../../common/widget.dart';
import '../../ui/stats/column_chart.dart';
import '../../ui/stats/radial_segment.dart';

class MockFamilyDeviceDetailScreen extends StatelessWidget {
  const MockFamilyDeviceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(builder: (context, height, width, sy, sx) {
      return ListView(
        children: [
          const SizedBox(height: 8),
          BackEditHeaderWidget(
            name: "Home",
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 8),
            child: Row(
              children: [
                Text("Status",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
              ],
            ),
          ),
          SizedBox(
            width: width > 600 ? 600 : width,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: MiniCard(
                child: Column(
                  children: [
                    MiniCardHeader(
                      text: "Activity",
                      icon: CupertinoIcons.chart_bar,
                      color: Color(0xff33c75a),
                      chevronIcon: Icons.chevron_right,
                    ),
                    const SizedBox(height: 4),
                    const RadialSegment(autoRefresh: true),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16),
            child: Text("Configuration",
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: MiniCard(
                child: MiniCardSummary(
                  header: MiniCardHeader(
                    text: "Blocklists",
                    icon: CupertinoIcons.shield,
                    color: Color(0xff3c8cff),
                    chevronIcon: Icons.chevron_right,
                    chevronText: "Alva",
                  ),
                  big: MiniCardCounter(counter: 8),
                  small: "selected",
                  //footer: "in safe search, ads, adult content, streaming apps",
                ),
              ),
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: MiniCard(
                child: MiniCardSummary(
                  header: MiniCardHeader(
                    text: "Unlocked mode",
                    icon: CupertinoIcons.lock_open,
                    color: Color(0xff3c8cff),
                    chevronIcon: Icons.chevron_right,
                    chevronText: "Adblocking only",
                  ),
                  big: MiniCardCounter(counter: 2),
                  small: "selected",
                  footer: "applies when Blokada is unlocked",
                ),
              ),
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: MiniCard(
                child: Column(
                  children: [
                    Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TwoLetterIconWidget(name: "Alva"),
                        SizedBox(width: 12),
                        Text("Alva",
                            style: TextStyle(
                              fontSize: 18,
                              color: context.theme.textSecondary,
                            )),
                        Expanded(child: Container()),
                        Text(
                          "Edit",
                          style: TextStyle(color: context.theme.family),
                        ),
                        SizedBox(width: 4),
                      ],
                    ),
                    //Toplist(stats: _stats, blocked: true),
                  ],
                ),
              ),
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: MiniCard(
                child: Column(
                  children: [
                    Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: context.theme.textPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(CupertinoIcons.power,
                              color: context.theme.bgColor, size: 24),
                        ),
                        SizedBox(width: 12),
                        Text("Enabled",
                            style: TextStyle(
                              fontSize: 18,
                              color: context.theme.textSecondary,
                            )),
                        Expanded(child: Container()),
                        CupertinoSwitch(
                          activeColor: context.theme.family,
                          value: true,
                          onChanged: (bool? value) {
                            // setState(() {
                            //   selected = value!;
                            // });
                          },
                        ),
                      ],
                    ),
                    //Toplist(stats: _stats, blocked: true),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: MiniCard(
                child: Column(
                  children: [
                    MiniCardHeader(
                      text: "Unlink this device",
                      icon: CupertinoIcons.link,
                      color: Colors.red,
                    ),
                    //Toplist(stats: _stats, blocked: false),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: sy(60)),
        ],
      );
    });
  }
}
