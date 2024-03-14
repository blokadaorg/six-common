import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:relative_scale/relative_scale.dart';

import '../../common/widget.dart';
import '../../common/widget/family/filter/filter_screen.dart';
import '../../common/widget/family/stats/stats_screen.dart';
import '../../ui/stats/radial_segment.dart';
import 'mock_scaffolding.dart';

class MockFamilyDeviceDetailThisScreen extends StatelessWidget {
  const MockFamilyDeviceDetailThisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(builder: (context, height, width, sy, sx) {
      return ListView(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 8),
            child: Row(
              children: [
                Text("My Device",
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
                onTap: () {
                  Navigator.push(
                    context,
                    StandardRoute(builder: (context) => const StatsScreen()),
                  );
                },
                child: const Column(
                  children: [
                    MiniCardHeader(
                      text: "Activity",
                      icon: CupertinoIcons.chart_bar,
                      color: Color(0xff33c75a),
                      chevronIcon: Icons.chevron_right,
                    ),
                    SizedBox(height: 4),
                    RadialSegment(autoRefresh: true),
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
                child: Column(
                  children: [
                    Row(
                      textBaseline: TextBaseline.alphabetic,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: context.theme.bgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(CupertinoIcons.power,
                              color: context.theme.textSecondary, size: 24),
                        ),
                        const SizedBox(width: 12),
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
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: MiniCard(
                onTap: () {
                  Navigator.push(
                    context,
                    StandardRoute(builder: (context) => const FilterScreen()),
                  );
                },
                child: MiniCardSummary(
                  header: MiniCardHeader(
                    text: "Blocklists",
                    icon: CupertinoIcons.shield,
                    color: Color(0xff3c8cff),
                    chevronIcon: Icons.chevron_right,
                    chevronText: "Adblocking only",
                  ),
                  big: MiniCardCounter(counter: 2),
                  small: "selected",
                  //footer: "applies when Blokada is unlocked",
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
                        const TwoLetterIconWidget(name: "iP"),
                        const SizedBox(width: 12),
                        Text("Name: iPhone 14 Pro",
                            style: TextStyle(
                              fontSize: 18,
                              color: context.theme.textSecondary,
                            )),
                        Expanded(child: Container()),
                        Text(
                          "Edit",
                          style: TextStyle(color: context.theme.family),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                    //Toplist(stats: _stats, blocked: true),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 24, right: 24),
            child: Text("Use different configuration when Blokada is locked:",
                style: TextStyle(color: Colors.black)),
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
                            color: context.theme.bgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(CupertinoIcons.lock,
                              color: context.theme.textSecondary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text("Lock Blokada",
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
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: MiniCard(
                onTap: () {
                  Navigator.push(
                    context,
                    StandardRoute(builder: (context) => const FilterScreen()),
                  );
                },
                child: const MiniCardSummary(
                  header: MiniCardHeader(
                    text: "Locked mode",
                    icon: CupertinoIcons.lock_shield,
                    color: Color(0xff3c8cff),
                    chevronIcon: Icons.chevron_right,
                    chevronText: "Block games",
                  ),
                  big: MiniCardCounter(counter: 8),
                  small: "selected",
                  footer: "applies when Blokada is locked",
                  //footer: "in safe search, ads, adult content, streaming apps",
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
                            color: context.theme.bgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(CupertinoIcons.ellipsis,
                              color: context.theme.textSecondary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text("Change pin",
                            style: TextStyle(
                              fontSize: 18,
                              color: context.theme.textSecondary,
                            )),
                        Expanded(child: Container()),
                        Text(
                          "Edit",
                          style: TextStyle(color: context.theme.family),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                    //Toplist(stats: _stats, blocked: true),
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
