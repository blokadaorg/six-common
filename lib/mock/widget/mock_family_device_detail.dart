import 'package:common/mock/widget/edit_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:relative_scale/relative_scale.dart';

import '../../common/widget.dart';
import '../../common/widget/family/filter/filter_screen.dart';
import '../../common/widget/family/stats/stats_screen.dart';
import '../../ui/stats/radial_segment.dart';
import 'mock_scaffolding.dart';

class MockFamilyDeviceDetailScreen extends StatelessWidget {
  const MockFamilyDeviceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text("STATISTICS",
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text("See the recent activity of this device.",
                  style: TextStyle(color: context.theme.textSecondary)),
            ),
            SizedBox(
              //width: width > 600 ? 600 : width,
              width: 600,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text("BLOCKING",
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                  "Edit the blocking profile to apply for this device. You can add new profiles in Settings.",
                  style: TextStyle(color: context.theme.textSecondary)),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: MiniCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      StandardRoute(builder: (context) => EditProfileSheet()),
                    );
                  },
                  child: Column(
                    children: [
                      MiniCardSummary(
                        header: MiniCardHeader(
                          text: "Profile",
                          icon: CupertinoIcons.person_crop_circle,
                          //color: Color(0xff3c8cff),
                          color: context.theme.family,
                          chevronIcon: Icons.chevron_right,
                          chevronText: "Child",
                        ),
                        big: MiniCardCounter(counter: 2),
                        small: "blocklists",
                        //footer: "applies when Blokada is unlocked",
                      ),
                      SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: context.theme.bgColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          textBaseline: TextBaseline.alphabetic,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 8),
                            Icon(CupertinoIcons.time,
                                color: context.theme.family, size: 24),
                            const SizedBox(width: 12),
                            Text("Pause blocking",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: context.theme.textPrimary,
                                )),
                            Expanded(child: Container()),
                            CupertinoSwitch(
                              activeColor: context.theme.family,
                              value: false,
                              onChanged: (bool? value) {
                                // setState(() {
                                //   selected = value!;
                                // });
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: MiniCard(
                  child: Text("Delete this device",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ),
            SizedBox(height: 48),
          ],
        ),
      ],
    );
  }
}
