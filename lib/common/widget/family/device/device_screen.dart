import 'package:common/common/widget.dart';
import 'package:common/mock/widget/mock_family_device_detail.dart';
import 'package:flutter/material.dart';
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
      body: Container(
        color: context.theme.bgColor,
        child: Stack(
          children: [
            const MockFamilyDeviceDetailScreen(),
            OverlayContainer(modal: _modal.now),
          ],
        ),
      ),
    );
  }
}
