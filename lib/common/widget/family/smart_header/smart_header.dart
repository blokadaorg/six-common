import 'package:common/common/widget.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../model.dart';
import '../home/add_device_sheet.dart';
import 'smart_header_button.dart';

class SmartHeader extends StatefulWidget {
  final FamilyPhase phase;

  const SmartHeader({super.key, required this.phase});

  @override
  State<StatefulWidget> createState() => SmartHeaderState();
}

class SmartHeaderState extends State<SmartHeader>
    with TickerProviderStateMixin {
  // bool _opened = false;

  // late final _ctrl = AnimationController(
  //   duration: const Duration(milliseconds: 400),
  //   vsync: this,
  // );
  //
  // late final _anim = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
  //   parent: _ctrl,
  //   curve: Curves.easeInOut,
  // ));

  // @override
  // void dispose() {
  //   super.dispose();
  //   _ctrl.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildButtons(context) +
                [
                  Spacer(),
                  SmartHeaderButton(
                      icon: CupertinoIcons.question_circle, onTap: () {}),
                ],
          ),
        ),
        //SmartHeaderOnboard(key: _containerKey, opened: _opened),
      ],
    );
  }

  List<Widget> _buildButtons(BuildContext context) {
    final list = <Widget>[];
    if (widget.phase == FamilyPhase.fresh ||
        widget.phase == FamilyPhase.parentNoDevices) {
      list.add(SmartHeaderButton(
          icon: CupertinoIcons.qrcode_viewfinder, onTap: () {}));
    }
    if (widget.phase == FamilyPhase.linkedUnlocked) {
      list.add(SmartHeaderButton(icon: CupertinoIcons.link, onTap: () {}));
    }
    if (widget.phase == FamilyPhase.parentHasDevices) {
      list.add(SmartHeaderButton(
          icon: CupertinoIcons.add_circled,
          onTap: () {
            showCupertinoModalBottomSheet(
              context: context,
              duration: const Duration(milliseconds: 300),
              backgroundColor: context.theme.bgColorCard,
              builder: (context) => AddDeviceSheet(),
            );
          }));
    }
    if (list.isEmpty) return list;
    return list.flatMap((e) => [e, SizedBox(width: 12)]).toList()..removeLast();
  }
}

// GestureDetector(
//   onTap: _playAnim,
//   child: SmartHeaderButton(
//       iconWidget: Padding(
//     padding: const EdgeInsets.all(12),
//     child: Opacity(
//       opacity: _opened ? 0 : 1,
//       child: Image.asset(
//         "assets/images/family-logo.png",
//         fit: BoxFit.contain,
//       ),
//     ),
//   )),
// ),
