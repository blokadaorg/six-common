import 'package:common/common/widget.dart';
import 'package:common/common/widget/family/home/big_icon.dart';
import 'package:common/common/widget/family/home/private_dns_sheet.dart';
import 'package:common/service/I18nService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:vistraced/via.dart';

import '../../../../lock/lock.dart';
import '../../../../stage/channel.pg.dart';
import '../../../../util/di.dart';
import '../../../model.dart';
import '../../../../util/trace.dart';
import 'add_device_sheet.dart';

part 'smart_onboard.g.dart';

class SmartOnboard extends StatefulWidget {
  final FamilyPhase phase;
  final int deviceCount;

  const SmartOnboard({
    super.key,
    required this.phase,
    required this.deviceCount,
  });

  @override
  State<StatefulWidget> createState() => _$SmartOnboardState();
}

@Injected(onlyVia: true, immediate: true)
class SmartOnboardState extends State<SmartOnboard>
    with TickerProviderStateMixin, Traceable, TraceOrigin {
  late final _modal = Via.as<StageModal?>();
  late final _lock = dep<LockStore>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getTexts(widget.phase, widget.deviceCount);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            //const SizedBox(height: 80),
            widget.deviceCount > 2
                ? SizedBox(
                    height: 64,
                    child: Image(
                      image: AssetImage('assets/images/header.png'),
                      width: 120,
                    ),
                  )
                : Container(height: 64),
            const SizedBox(height: 52),
            BigIcon(
              icon: getIcon(widget.phase),
              canShowLogo: !(widget.phase == FamilyPhase.parentHasDevices &&
                  widget.deviceCount > 2),
            ),
            const SizedBox(height: 90),
            Text(
              texts.first!,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (texts.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: SizedBox(
                  height: 80,
                  child: Text(
                    texts[1]!,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                  ),
                ),
              ),
            Spacer(),
            SizedBox(
              height: 64,
              child: widget.phase.requiresBobo()
                  ? _buildButton(context)
                  : Container(),
            ),
            SizedBox(height: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
      child: MiniCard(
        onTap: _handleCtaTap,
        color: context.theme.accent,
        child: SizedBox(
          height: 32,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                getIcon(widget.phase, forCta: true),
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Center(
                child: Text(
                  getCtaText(widget.phase),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _handleCtaTap() {
    final p = widget.phase;

    if (p.requiresActivation()) {
      _modal.set(StageModal.payment);
    } else if (p.requiresPerms()) {
      showCupertinoModalBottomSheet(
        context: context,
        duration: const Duration(milliseconds: 300),
        backgroundColor: context.theme.bgColorCard,
        builder: (context) => PrivateDnsSheet(),
      );
    } else if (p.isLocked2()) {
      _modal.set(StageModal.lock);
      // } else if (!_devices.now.hasThisDevice) {
      // await _modal.set(StageModal.onboardingAccountDecided);
    } else if (p == FamilyPhase.linkedUnlocked) {
      traceAs("tappedLock", (trace) async {
        await _lock.autoLock(trace);
      });
    } else {
      showCupertinoModalBottomSheet(
        context: context,
        duration: const Duration(milliseconds: 300),
        backgroundColor: context.theme.bgColorCard,
        builder: (context) => AddDeviceSheet(),
      );
    }
  }

  List<String?> _getTexts(FamilyPhase phase, int devicesCount) {
    switch (phase) {
      case FamilyPhase.fresh:
        return [
          "family status fresh header".i18n,
          "${"family status fresh body".i18n}\n\n",
        ];
      case FamilyPhase.parentNoDevices:
        return [
          "family status ready header".i18n,
          "${"family status ready body".i18n}\n\n",
        ];
      case FamilyPhase.linkedUnlocked:
        return [
          "family status linked header".i18n,
          "Use the parent device to manage this device\n\n",
        ];
      case FamilyPhase.linkedNoPerms ||
            FamilyPhase.lockedNoPerms ||
            FamilyPhase.noPerms:
        return [
          "family status perms header".i18n,
          "${"family status perms body".i18n}\n\n",
        ];
      case FamilyPhase.lockedNoAccount:
        return [
          "family status expired header".i18n,
          "${"family status expired body".i18n}\n\n",
        ];
      case FamilyPhase.lockedActive || FamilyPhase.linkedActive:
        return [
          "family status locked header".i18n,
        ];
      case FamilyPhase.parentHasDevices:
        if (devicesCount > 1) {
          return ["", ""];
        } else {
          return [
            "Active!",
            "Tap the device for details\n\n",
          ];
        }
      case FamilyPhase.starting:
        return ["", "Please wait..."];
      default:
        return ["", ""];
    }
  }
}

IconData? getIcon(FamilyPhase phase, {bool forCta = false}) {
  switch (phase) {
    case FamilyPhase.fresh || FamilyPhase.lockedNoAccount:
      return CupertinoIcons.person_crop_circle;
    case FamilyPhase.parentNoDevices:
      return CupertinoIcons.add_circled;
    case FamilyPhase.linkedActive || FamilyPhase.lockedActive:
      return CupertinoIcons.lock;
    case FamilyPhase.linkedUnlocked:
      if (forCta) return CupertinoIcons.lock;
      return CupertinoIcons.link;
    case FamilyPhase.linkedNoPerms ||
          FamilyPhase.lockedNoPerms ||
          FamilyPhase.noPerms:
      return Icons.key;
    default:
      return null;
  }
}

String getCtaText(FamilyPhase p) {
  if (p == FamilyPhase.linkedUnlocked) {
    //return "family account cta unlink".i18n;
    return "Lock";
  } else if (p.requiresPerms()) {
    return "family cta action finish setup".i18n;
  } else if (p.requiresActivation()) {
    return "family cta action activate".i18n;
  } else if (p.isLocked2()) {
    return "Unlock";
  } else {
    return "family cta action add device".i18n;
  }
}
