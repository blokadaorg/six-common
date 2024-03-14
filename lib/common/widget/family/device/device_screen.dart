import 'package:common/common/widget.dart';
import 'package:common/mock/widget/mock_family_device_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';
import 'package:vistraced/via.dart';

import '../../../../stage/channel.pg.dart';
import '../../../../ui/overlay/overlay_container.dart';

part 'device_screen.g.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({Key? key}) : super(key: key);

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
          largeTitle: SuperLargeTitle(largeTitle: "Alva"),
          previousPageTitle: "Home",
          actions: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => {},
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
            const MockFamilyDeviceDetailScreen(),
            OverlayContainer(modal: _modal.now),
          ],
        ),
      ),
    );
  }
}
