import 'package:flutter/material.dart';
import 'package:vistraced/via.dart';

import '../../../model.dart';
import '../../../widget.dart';
import '../../../../util/trace.dart';
import '../device/device_screen.dart';

part 'device.g.dart';

class HomeDevice extends StatefulWidget {
  final void Function()? onLongPress;
  final FamilyDevice device;
  final Color color;

  const HomeDevice({
    Key? key,
    this.onLongPress,
    required this.device,
    required this.color,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _$HomeDeviceState();
}

@Injected(onlyVia: true, immediate: true)
class HomeDeviceState extends State<HomeDevice>
    with TickerProviderStateMixin, TraceOrigin {
  @MatcherSpec(of: "stage")
  late final _route = Via.as<String>();

  @MatcherSpec(of: "family")
  late final _selectedDevice = Via.as<String>();

  _onTap() async {
    if (widget.device.deviceName.isEmpty) return;
    await _selectedDevice.set(widget.device.deviceName);

    Navigator.push(
      context,
      StandardRoute(builder: (context) => const DeviceScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: MiniCard(
        onTap: _onTap,
        // outlined: widget.thisDevice,
        outlined: false,
        child: Column(
          children: [
            MiniCardHeader(
              text: widget.device.deviceDisplayName,
              icon: widget.device.thisDevice
                  ? Icons.phonelink_lock
                  : Icons.phone_iphone,
              color: widget.color,
              chevronIcon: Icons.chevron_right,
            ),
            const SizedBox(height: 20),
            IgnorePointer(
              ignoring: true,
              child: MiniCardChart(device: widget.device, color: widget.color),
            ),
          ],
          //footer: "home status detail active".i18n.replaceAll("*", ""),
        ),
      ),
    );
  }
}
