import 'package:common/common/dialog.dart';
import 'package:common/common/navigation.dart';
import 'package:common/common/widget/bottom_sheet.dart';
import 'package:common/common/widget/minicard/minicard.dart';
import 'package:common/common/widget/theme.dart';
import 'package:common/core/core.dart';
import 'package:common/family/module/device_v3/device.dart';
import 'package:common/family/module/family/family.dart';
import 'package:common/family/widget/home/device/home_device.dart';
import 'package:common/family/widget/home/link_device_sheet.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomeDevices extends StatefulWidget {
  final FamilyDevices devices;

  const HomeDevices({super.key, required this.devices});

  @override
  HomeDevicesState createState() => HomeDevicesState();
}

class HomeDevicesState extends State<HomeDevices>
    with TickerProviderStateMixin, Logging {
  late final _slidableOnboarding = Core.get<SlidableOnboarding>();

  late final AnimationController _ctrl = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(HomeDevices oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devices = _getDevices(context);

    if (!isTabletMode(context) || devices.length < 2) {
      // One pane view
      return Container(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: ListView(
          reverse: true,
          children: [_buildAddDeviceButton(context)] + devices,
        ),
      );
    } else {
      // Two pane view
      return Container(
        constraints: const BoxConstraints(maxWidth: maxContentWidth * 2),
        child: ListView(
          reverse: true,
          children: [
            _buildAddDeviceButton(context),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  children: List.generate(
                      (devices.length / 2).floor(),
                      (index) => SizedBox(
                            width: maxContentWidth,
                            child:
                                devices[(devices.length - 1) - (2 * index + 1)],
                          )),
                ),
                Column(
                  children: List.generate(
                      (devices.length / 2).ceil(),
                      (index) => SizedBox(
                            width: maxContentWidth,
                            child: devices[(devices.length - 1) - (2 * index)],
                          )),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Group devices in pairs and allow vertical carousel scrolling
    // final d = devices.reversed.toList();
    // final pairs = Iterable.generate((d.length / 2).ceil(), (index) => index * 2)
    //     .map((i) =>
    //         _pairWidget(d.sublist(i, i + 2 >= d.length ? d.length : i + 2)))
    //     .toList();
    //
    // return Column(
    //   children: [
    //     Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
    //       child: Row(
    //         children: [
    //           _buildAddDeviceButton(context),
    //           const Spacer(),
    //           Touch(
    //               onTap: () {
    //                 _carouselCtrl.nextPage();
    //               },
    //               decorationBuilder: (value) {
    //                 return BoxDecoration(
    //                   color: context.theme.bgMiniCard.withOpacity(value),
    //                   borderRadius: BorderRadius.circular(4),
    //                 );
    //               },
    //               child: const Padding(
    //                 padding: EdgeInsets.all(4.0),
    //                 child: Icon(
    //                   CupertinoIcons.chevron_up,
    //                   size: 18,
    //                   color: Colors.white,
    //                 ),
    //               )),
    //           Touch(
    //               onTap: () {
    //                 _carouselCtrl.previousPage();
    //               },
    //               decorationBuilder: (value) {
    //                 return BoxDecoration(
    //                   color: context.theme.bgMiniCard.withOpacity(value),
    //                   borderRadius: BorderRadius.circular(4),
    //                 );
    //               },
    //               child: const Padding(
    //                 padding: EdgeInsets.all(4.0),
    //                 child: Icon(
    //                   CupertinoIcons.chevron_down,
    //                   size: 18,
    //                   color: Colors.white,
    //                 ),
    //               )),
    //         ],
    //       ),
    //     ),
    //     CarouselSlider(
    //         items: d.sublist(1),
    //         carouselController: _carouselCtrl,
    //         options: CarouselOptions(
    //           height: 186,
    //           //aspectRatio: 16 / 9,
    //           viewportFraction: 1.0,
    //           initialPage: d.length - 1 - 1,
    //           enableInfiniteScroll: true,
    //           reverse: true,
    //           autoPlay: true,
    //           autoPlayInterval: const Duration(seconds: 10),
    //           enlargeCenterPage: false,
    //           scrollDirection: Axis.vertical,
    //         )),
    //     d.first,
    //   ],
    // );
  }

  Widget _pairWidget(List<Widget> widgets) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: widgets.reversed.toList(),
    );
  }

  List<Widget> _getDevices(BuildContext context) {
    final priorityDevices = <FamilyDevice>[];
    if (widget.devices.hasThisDevice) {
      priorityDevices
          .add(widget.devices.entries.firstWhere((it) => it.thisDevice));
    }

    return (priorityDevices +
            widget.devices.entries.filter((e) => !e.thisDevice).toList())
        .map((e) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: _wrapInDismissible(
              context,
              e,
              HomeDevice(
                  device: e,
                  color: e.thisDevice
                      ? context.theme.accent
                      : const Color(0xff3c8cff)),
            )))
        .toList();
  }

  Widget _wrapInDismissible(
      BuildContext context, FamilyDevice d, Widget child) {
    return Slidable(
      key: Key(d.device.alias),
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (c) =>
                showSelectProfileDialog(context, device: d.device),
            backgroundColor: context.theme.textPrimary.withOpacity(0.15),
            foregroundColor: Colors.white,
            icon: CupertinoIcons.profile_circled,
            label: "family stats label profile".i18n,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
        ],
      ),
      child: Builder(builder: (context) {
        _showSlidableActionToUser(Slidable.of(context));
        return child;
      }),
    );
  }

  // To show to user, that the slidable options are available
  _showSlidableActionToUser(SlidableController? ctrl) async {
    if (ctrl == null) return;
    if (await _slidableOnboarding.fetch(Markers.ui) == true) return;
    _slidableOnboarding.change(Markers.ui, true);

    Future.delayed(const Duration(milliseconds: 500), () {
      ctrl.openEndActionPane();
    });

    Future.delayed(const Duration(seconds: 2), () {
      ctrl.close();
    });
  }

  Widget _buildAddDeviceButton(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: MiniCard(
            onTap: () {
              showSheet(
                context,
                builder: (context) => const LinkDeviceSheet(),
              );
            },
            color: context.theme.accent,
            child: SizedBox(
              height: 32,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.plus_circle,
                      size: 28,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "family device header add".i18n,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
