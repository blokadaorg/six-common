import 'package:common/common/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';
import 'package:vistraced/via.dart';

import '../../../../mock/widget/edit_profile.dart';
import '../../../../stage/channel.pg.dart';
import '../../../../ui/overlay/overlay_container.dart';
import '../../../model.dart';
import '../stats/radial_segment.dart';
import '../stats/stats_screen.dart';

part 'device_screen.g.dart';

class DeviceScreen extends StatefulWidget {
  final FamilyDevice device;

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceScreen> createState() => _$DeviceScreenState();
}

@Injected(onlyVia: true, immediate: true)
class DeviceScreenState extends State<DeviceScreen>
    with ViaTools<DeviceScreen> {
  late final _modal = Via.as<StageModal?>()..also(rebuild);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.bgColor,
      body: SuperScaffold(
        appBar: SuperAppBar(
          searchBar: SuperSearchBar(enabled: false),
          backgroundColor: context.theme.panelBackground.withOpacity(0.5),
          largeTitle:
              SuperLargeTitle(largeTitle: widget.device.deviceDisplayName),
          previousPageTitle: "Home",
          actions: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => showInputDialog(context,
                    title: "Edit device",
                    desc: "Enter a name for this device.",
                    inputValue: widget.device.deviceName, onConfirm: (value) {
                  print("Value: $value");
                }),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text("Edit",
                      style: TextStyle(color: context.theme.family)),
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(height: 32),
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
                          StandardRoute(
                              builder: (context) =>
                                  StatsScreen(device: widget.device)),
                        );
                      },
                      child: Column(
                        children: [
                          MiniCardHeader(
                            text: "Activity",
                            icon: CupertinoIcons.chart_bar,
                            color: Color(0xff33c75a),
                            chevronIcon: Icons.chevron_right,
                          ),
                          SizedBox(height: 4),
                          RadialSegment(device: widget.device),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32),
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
                          StandardRoute(
                              builder: (context) => EditProfileSheet(
                                    previous: widget.device.deviceDisplayName,
                                    profile: widget.device.thisDevice
                                        ? "Parent"
                                        : "Child",
                                  )),
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
                              chevronText:
                                  widget.device.thisDevice ? "Parent" : "Child",
                            ),
                            big: MiniCardCounter(counter: 2),
                            small: "blocklists",
                            //footer: "applies when Blokada is unlocked",
                          ),
                          SizedBox(height: 8),
                          Divider(
                            color: context.theme.divider,
                            height: 1,
                            thickness: 0.2,
                          ),
                          SizedBox(height: 8),
                          Row(
                            textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                widget.device.thisDevice
                    ? Container()
                    : Container(
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
            OverlayContainer(modal: _modal.now),
          ],
        ),
      ),
    );
  }
}
