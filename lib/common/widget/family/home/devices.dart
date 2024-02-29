import 'package:carousel_slider/carousel_slider.dart';
import 'package:common/service/I18nService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:vistraced/via.dart';

import '../../../../family/family.dart';
import '../../../../util/di.dart';
import '../../../widget.dart';
import '../../../../family/devices.dart';
import '../../../../util/trace.dart';
import 'add_device_sheet.dart';
import 'device.dart';

part 'devices.g.dart';

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  DevicesState createState() => _$DevicesState();
}

@Injected(onlyVia: true, immediate: true)
class DevicesState extends State<Devices>
    with ViaTools<Devices>, TickerProviderStateMixin, Traceable, TraceOrigin {
  late final _devices = Via.as<FamilyDevices>()..also(rebuild);
  late final _family = dep<FamilyStore>();

  late final AnimationController _ctrl = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  );

  final CarouselController _carouselCtrl = CarouselController();

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
    _devices.fetch(notify: true);
  }

  @override
  void dispose() {
    super.dispose();
    _ctrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devices = _getDevices();

    if (devices.length <= 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[] +
            //devices +
            // [
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.start,
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.symmetric(
            //             horizontal: 16.0, vertical: 8),
            //         child: SmartHeaderButton(icon: CupertinoIcons.plus_circle),
            //       ),
            //       //_buildAddDeviceButton2(context),
            //     ],
            //   ),
            // ] +
            devices,
      );
    }

    // Group devices in pairs and allow vertical carousel scrolling
    final d = devices.reversed.toList();
    final pairs = Iterable.generate((d.length / 2).ceil(), (index) => index * 2)
        .map((i) =>
            _pairWidget(d.sublist(i, i + 2 >= d.length ? d.length : i + 2)))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
          child: Row(
            children: [
              _buildAddDeviceButton(context),
              Spacer(),
              Touch(
                  onTap: () {
                    _carouselCtrl.nextPage();
                  },
                  decorationBuilder: (value) {
                    return BoxDecoration(
                      color: context.theme.bgMiniCard.withOpacity(value),
                      borderRadius: BorderRadius.circular(4),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      CupertinoIcons.chevron_up,
                      size: 18,
                      color: Colors.white,
                    ),
                  )),
              Touch(
                  onTap: () {
                    _carouselCtrl.previousPage();
                  },
                  decorationBuilder: (value) {
                    return BoxDecoration(
                      color: context.theme.bgMiniCard.withOpacity(value),
                      borderRadius: BorderRadius.circular(4),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      CupertinoIcons.chevron_down,
                      size: 18,
                      color: Colors.white,
                    ),
                  )),
            ],
          ),
        ),
        CarouselSlider(
            items: d.sublist(1),
            carouselController: _carouselCtrl,
            options: CarouselOptions(
              height: 186,
              //aspectRatio: 16 / 9,
              viewportFraction: 1.0,
              initialPage: d.length - 1 - 1,
              enableInfiniteScroll: true,
              reverse: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 10),
              enlargeCenterPage: false,
              scrollDirection: Axis.vertical,
            )),
        d.first,
      ],
    );
  }

  Widget _pairWidget(List<Widget> widgets) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: widgets.reversed.toList(),
    );
  }

  List<Widget> _getDevices() {
    if (_devices.dirty) return [];
    return _devices.now.entries.reversed
        .map((e) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: _wrapInDismissible(
              e.thisDevice,
              e.deviceName,
              HomeDevice(
                  device: e,
                  color: e.thisDevice
                      ? context.theme.family
                      : const Color(0xff3c8cff)),
            )))
        .toList();
  }

  Widget _wrapInDismissible(bool thisDevice, String deviceName, Widget child) {
    return Slidable(
      key: Key(deviceName),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (context) => _delete(deviceName),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: thisDevice ? CupertinoIcons.power : CupertinoIcons.delete,
            label: thisDevice
                ? "universal action disable".i18n
                : "universal action delete".i18n,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
        ],
      ),
      child: child,
    );
  }

  void _delete(String deviceName) {
    traceAs("tappedDeleteDevice", (trace) async {
      //_devices.now.deleteDevice(deviceName);
      _family.deleteDevice(trace, deviceName);
    });
  }

  Widget _buildAddDeviceButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: Touch(
        onTap: () {
          showCupertinoModalBottomSheet(
            context: context,
            duration: const Duration(milliseconds: 300),
            backgroundColor: context.theme.bgColorCard,
            builder: (context) => AddDeviceSheet(),
          );
        },
        decorationBuilder: (value) {
          return BoxDecoration(
            color: context.theme.bgMiniCard.withOpacity(value),
            borderRadius: BorderRadius.circular(4),
          );
        },
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Icon(
            CupertinoIcons.plus_circle,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAddDeviceButton2(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MiniCard(
        onTap: () {
          showCupertinoModalBottomSheet(
            context: context,
            duration: const Duration(milliseconds: 300),
            backgroundColor: context.theme.bgColorCard,
            builder: (context) => AddDeviceSheet(),
          );
        },
        color: context.theme.family,
        child: SizedBox(
          height: 32,
          child: Center(
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.plus,
                  size: 28,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  "Add a device",
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
