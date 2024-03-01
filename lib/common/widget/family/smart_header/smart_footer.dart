import 'dart:ui';

import 'package:common/common/widget/family/home/add_device_sheet.dart';
import 'package:common/common/widget/family/home/smart_onboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:vistraced/via.dart';

import '../../../../stage/channel.pg.dart';
import '../../../model.dart';
import '../../../widget.dart';
import '../home/private_dns_sheet.dart';

part 'smart_footer.g.dart';

class SmartFooter extends StatefulWidget {
  final FamilyPhase phase;
  final bool hasPin;

  const SmartFooter({super.key, required this.phase, required this.hasPin});

  @override
  State<StatefulWidget> createState() => _$SmartFooterState();
}

@Injected(onlyVia: true, immediate: true)
class SmartFooterState extends State<SmartFooter> with ViaTools<SmartFooter> {
  @MatcherSpec(of: "familyUnlink")
  late final _unlink = Via.call();
  late final _modal = Via.as<StageModal?>();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, widget.phase.hasBottomBar() ? 0 : 94),
      child: SizedBox(
        height: 94,
        child: Stack(
          children: [
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 25,
                  sigmaY: 25,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.theme.panelBackground.withOpacity(0.2),
                    border: Border(
                      top: BorderSide(
                        width: 1,
                        color: context.theme.divider.withOpacity(0.05),
                      ),
                    ),
                  ),
                  height: 104,
                  //color: context.theme.divider.withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.phase.requiresBobo()
                    ? [
                        _buildButton(context),
                      ]
                    : _buildTabs(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTabs(BuildContext context) {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 48,
          child: Column(
            children: [
              Icon(
                CupertinoIcons.home,
                color: context.theme.family,
              ),
              Text("Home", style: TextStyle(color: context.theme.family))
            ],
          ),
        ),
      ),
      SizedBox(width: 32),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 48,
          child: Column(
            children: [
              Icon(
                CupertinoIcons.device_phone_portrait,
                color: context.theme.textPrimary,
              ),
              Text("My Device",
                  style: TextStyle(color: context.theme.textPrimary))
            ],
          ),
        ),
      ),
      SizedBox(width: 32),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 48,
          child: Column(
            children: [
              Icon(
                CupertinoIcons.settings,
                color: context.theme.textPrimary,
              ),
              Text("Settings",
                  style: TextStyle(color: context.theme.textPrimary))
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildButton(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
        child: MiniCard(
          onTap: _handleCtaTap,
          color: context.theme.family,
          child: SizedBox(
            height: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  getIcon(widget.phase),
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
    } else {
      showCupertinoModalBottomSheet(
        context: context,
        duration: const Duration(milliseconds: 300),
        backgroundColor: context.theme.bgColorCard,
        builder: (context) => AddDeviceSheet(),
      );
    }
  }
}
