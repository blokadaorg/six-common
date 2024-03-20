import 'package:common/common/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:vistraced/via.dart';

import '../../../../stage/channel.pg.dart';
import '../../../model.dart';
import '../home/profiles_sheet.dart';
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
    _scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    Provider.of<TopBarController>(context, listen: false)
        .updateScrollPos(_scrollController.offset);
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
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
              Center(
                child: Text(widget.device.deviceDisplayName,
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              ),
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
                                Icon(CupertinoIcons.person_crop_circle,
                                    color: context.theme.textSecondary,
                                    size: 18),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    "Profile",
                                    style: TextStyle(
                                      color: context.theme.textSecondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showCupertinoModalBottomSheet(
                                      context: context,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      backgroundColor:
                                          context.theme.bgColorCard,
                                      builder: (context) => ProfilesSheet(),
                                    );
                                  },
                                  child: Text("Select",
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
                                Text(
                                    widget.device.thisDevice
                                        ? "Parent"
                                        : "Child",
                                    style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w500,
                                        color: context.theme.textPrimary)),
                                Spacer(),
                                Text("2 blocklists",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: context.theme.textPrimary)),
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
