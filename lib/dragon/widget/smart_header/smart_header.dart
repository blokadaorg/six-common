import 'dart:async';

import 'package:common/common/model.dart';
import 'package:common/dragon/support/support_unread.dart';
import 'package:common/dragon/widget/navigation.dart';
import 'package:common/dragon/widget/smart_header/smart_header_button.dart';
import 'package:common/lock/lock.dart';
import 'package:common/logger/logger.dart';
import 'package:common/stage/stage.dart';
import 'package:common/util/di.dart';
import 'package:flutter/cupertino.dart';

class SmartHeader extends StatefulWidget {
  final FamilyPhase phase;

  const SmartHeader({super.key, required this.phase});

  @override
  State<StatefulWidget> createState() => SmartHeaderState();
}

class SmartHeaderState extends State<SmartHeader>
    with TickerProviderStateMixin, Logging {
  late final _lock = dep<LockStore>();
  late final _stage = dep<StageStore>();
  late final _unread = dep<SupportUnread>();

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

  late StreamSubscription? _unreadSub;

  @override
  void initState() {
    super.initState();
    _unread.fetch();
    _unreadSub = _unread.onChange.listen((it) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _unreadSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildButtons(context),
          ),
        ),
        //SmartHeaderOnboard(key: _containerKey, opened: _opened),
      ],
    );
  }

  List<Widget> _buildButtons(BuildContext context) {
    final list = <Widget>[];

    list.add(const Spacer());

    if (!widget.phase.isLocked2() &&
        widget.phase != FamilyPhase.linkedExpired) {
      // list.add(SmartHeaderButton(
      //     icon: _lock.hasPin ? CupertinoIcons.lock : CupertinoIcons.lock_open,
      //     onTap: () {
      //       //_modal.set(StageModal.lock);
      //       traceAs("tappedLock", () async {
      //         await _lock.autoLock;
      //       });
      //     }));
      list.add(SmartHeaderButton(
          icon: CupertinoIcons.person_crop_circle,
          onTap: () {
            Navigation.open(context, Paths.settings);
          }));
      list.add(const SizedBox(width: 4));
    }

    // list.add(SmartHeaderButton(
    //     unread: _unread.now,
    //     icon: CupertinoIcons.question_circle,
    //     onTap: () {
    //       Navigation.open(context, Paths.support);
    //       // traceAs("tappedHelp", () async {
    //       //   _stage.showModal(StageModal.help);
    //       // });
    //       // showCupertinoModalBottomSheet(
    //       //   context: context,
    //       //   duration: const Duration(milliseconds: 300),
    //       //   backgroundColor: context.theme.bgColorCard,
    //       //   builder: (context) => PaymentSheet(),
    //       // );
    //
    //     }));

    return list;
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
