import 'package:common/common/widget.dart';
import 'package:common/common/widget/family/home/devices.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vistraced/via.dart';

import '../../../../mock/widget/add_profile_sheet.dart';
import '../../../../stage/channel.pg.dart';
import '../../../model.dart';
import '../../avatar_icon.dart';
import '../home/top_bar.dart';
import '../stats/radial_segment.dart';

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

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateTopBar);
    _updateTopBar();
  }

  void _updateTopBar() {
    Provider.of<TopBarController>(context, listen: false)
        .updateScrollPos(_scrollController.offset);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateTopBar);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.bgColor,
      body: Container(
        child: PrimaryScrollController(
          controller: _scrollController,
          child: ListView(
            primary: true,
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: 100),
              Column(
                children: [
                  SizedBox(height: 12),
                  AvatarIconWidget(
                      name: widget.device.thisDevice
                          ? null
                          : widget.device.deviceDisplayName,
                      color: widget.device.thisDevice
                          ? context.theme.family
                          : Color(0xff3c8cff)),
                  SizedBox(height: 8),
                  Text(
                      widget.device.thisDevice
                          ? widget.device.deviceDisplayName
                          : widget.device.deviceDisplayName + " device",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                  widget.device.thisDevice
                      ? Container()
                      : GestureDetector(
                          onTap: () {
                            showRenameDialog(
                                context, "device", widget.device.deviceName);
                          },
                          child: Text("Edit",
                              style: TextStyle(color: context.theme.family)),
                        ),
                ],
              ),
              SizedBox(height: 40),
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
                      Navigator.pushNamed(
                        context,
                        "/device/stats",
                        arguments: widget.device,
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
                      Navigator.pushNamed(
                        context,
                        "/device/profile",
                        arguments: widget.device,
                      );
                    },
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                    widget.device.thisDevice
                                        ? CupertinoIcons.person_2_alt
                                        : CupertinoIcons.person_solid,
                                    color: widget.device.thisDevice
                                        ? Colors.blue
                                        : Colors.green,
                                    size: 18),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.device.thisDevice
                                        ? "Parent"
                                        : "Child",
                                    style: TextStyle(
                                      color: widget.device.thisDevice
                                          ? Colors.blue
                                          : Colors.green,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // showCupertinoModalBottomSheet(
                                    //   context: context,
                                    //   duration:
                                    //       const Duration(milliseconds: 300),
                                    //   backgroundColor:
                                    //       context.theme.bgColorCard,
                                    //   builder: (context) => ProfilesSheet(),
                                    // );
                                    showSelectProfileDialog(context,
                                        deviceName:
                                            widget.device.deviceDisplayName);
                                  },
                                  child: Text("Select profile",
                                      style: TextStyle(
                                          color: context.theme.family)),
                                ),
                                const SizedBox(width: 4),
                              ],
                            ),
                            SizedBox(height: 32),
                            Row(
                              textBaseline: TextBaseline.alphabetic,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              children: [
                                Text("2 blocklists",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w400)),
                                Spacer(),
                                Text("Modify",
                                    style: TextStyle(
                                        color: context.theme.textSecondary)),
                                const SizedBox(width: 4),
                                Transform.translate(
                                  offset: const Offset(0, 6),
                                  child: Icon(Icons.chevron_right,
                                      color: context.theme.textSecondary),
                                ),
                              ],
                            ),
                          ],
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
                        padding: EdgeInsets.all(18.0),
                        child: Text("Delete this device",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
              SizedBox(height: 48),
            ],
          ),
        ),
      ),
      //),
    );
  }
}
