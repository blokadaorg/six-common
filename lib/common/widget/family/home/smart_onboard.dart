import 'package:common/common/widget.dart';
import 'package:common/common/widget/family/home/big_icon.dart';
import 'package:common/service/I18nService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../model.dart';
import '../../../../util/trace.dart';

class SmartOnboard extends StatefulWidget {
  final FamilyPhase phase;
  final bool hasMultipleDevices;

  const SmartOnboard(
      {super.key, required this.phase, required this.hasMultipleDevices});

  @override
  State<StatefulWidget> createState() => SmartOnboardState();
}

class SmartOnboardState extends State<SmartOnboard>
    with TickerProviderStateMixin, Traceable, TraceOrigin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final texts = _getTexts(widget.phase);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Center(
        child: Column(
          children: [
            BigIcon(
              icon: getIcon(widget.phase),
              canShowLogo: !(widget.phase == FamilyPhase.parentHasDevices &&
                  widget.hasMultipleDevices),
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  List<String?> _getTexts(FamilyPhase phase) {
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
      case FamilyPhase.starting:
        return [
          " ",
          "Please wait... baby aheusau htaou snthaoe s unthaeosut haoehusaeoht uaesontuhaoesntuhaeosnt uhaueos hsau"
        ];
      default:
        return [" ", " "];
    }
  }
}

IconData? getIcon(FamilyPhase phase) {
  switch (phase) {
    case FamilyPhase.fresh || FamilyPhase.lockedNoAccount:
      return CupertinoIcons.person_crop_circle;
    case FamilyPhase.parentNoDevices:
      return CupertinoIcons.add_circled;
    case FamilyPhase.linkedActive || FamilyPhase.lockedActive:
      return CupertinoIcons.lock;
    case FamilyPhase.linkedUnlocked:
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
    return "family account cta unlink".i18n;
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
