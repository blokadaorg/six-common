import 'package:common/app/app.dart';
import 'package:common/common/widget/family/home/animated_bg.dart';
import 'package:common/service/I18nService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:relative_scale/relative_scale.dart';
import 'package:vistraced/via.dart';

import '../../../../app/channel.pg.dart';
import '../../../../family/devices.dart';
import '../../../../family/family.dart';
import '../../../../stage/channel.pg.dart';
import '../../../../ui/debug/commanddialog.dart';
import '../../../../ui/overlay/overlay_container.dart';
import '../../../../util/di.dart';
import '../../../../util/trace.dart';
import '../../../model.dart';
import '../../../widget.dart';
import '../smart_header/smart_footer.dart';
import '../smart_header/smart_header.dart';
import 'bg.dart';
import 'big_logo.dart';
import 'cta_buttons.dart';
import 'devices.dart';
import 'smart_onboard.dart';
import 'status_texts.dart';

part 'home_screen.g.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _$HomeScreenState();
}

@Injected(onlyVia: true, immediate: true)
class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, Traceable, TraceOrigin {
  late final _status = Via.as<AppStatus>()..also(rebuild);
  late final _phase = Via.as<FamilyPhase>()..also(rebuild);
  late final _devices = Via.as<FamilyDevices>()..also(rebuild);
  late final _modal = Via.as<StageModal?>()..also(rebuild);

  @MatcherSpec(of: "stage")
  late final _ready = Via.as<bool>()..also(rebuild);

  var _working = true;

  rebuild() {
    print("home screen rebuild called");
    setState(() => _working = _status.now.isWorking() || !_ready.now);
  }

  @override
  Widget build(BuildContext context) {
    final phase = _phase.now;
    final hasMultiple = _devices.now.entries.length > 1;

    return Scaffold(
        body: Stack(
      children: [
        AnimatedBg(),
        phase == FamilyPhase.parentHasDevices
            ? ListView(
                reverse: true,
                children: [
                  SizedBox(height: 64),
                  Devices(),
                ],
              )
            : Container(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SmartOnboard(phase: phase, hasMultipleDevices: hasMultiple),
          ],
        ),
        Column(
          children: [
            SizedBox(height: 48),
            SmartHeader(phase: phase),
          ],
        ),
        Column(
          children: [
            Spacer(),
            SmartFooter(phase: phase, hasPin: true),
          ],
        ),
        OverlayContainer(modal: _modal.now),
      ],
    ));
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: FamilyBgWidget(
  //       child: Stack(
  //         children: [
  //           Container(
  //             child: Stack(
  //               alignment: Alignment.topCenter,
  //               children: [
  //                 const BigLogo(),
  //                 _buildHelpButton(),
  //                 AbsorbPointer(
  //                   absorbing: false,
  //                   child: Padding(
  //                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //                     child: RelativeBuilder(
  //                         builder: (context, height, width, sy, sx) {
  //                       return Container(
  //                         constraints: const BoxConstraints(maxWidth: 500),
  //                         child: Stack(
  //                           alignment: Alignment.center,
  //                           children: [
  //                             // Main home screen content
  //                             Column(
  //                               mainAxisSize: MainAxisSize.max,
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 const Spacer(),
  //
  //                                 // Devices list or the status texts
  //                                 (_phase.now == FamilyPhase.parentHasDevices)
  //                                     ? const Devices()
  //                                     : StatusTexts(phase: _phase.now),
  //                                 CtaButtons(),
  //
  //                                 // Leave space for navbar
  //                                 // (!_phase.now.isLocked())
  //                                 //     ? SizedBox(height: sy(40))
  //                                 //     : Container(),
  //                                 SizedBox(height: sy(24)),
  //                               ],
  //                             ),
  //
  //                             // Loading spinner on covering the content
  //                             _buildLoadingSpinner(context),
  //                           ],
  //                         ),
  //                       );
  //                     }),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           OverlayContainer(modal: _modal.now),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  _buildHelpButton() {
    return GestureDetector(
      onDoubleTap: () => _showCommandDialog(context),
      child: Padding(
        padding: const EdgeInsets.only(top: 60, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            HomeIcon(
              icon: CupertinoIcons.question_circle,
              alwaysWhite: true,
              onTap: () {
                traceAs("tappedShowHelp", (trace) async {
                  await _modal.set(StageModal.help);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  _buildLoadingSpinner(BuildContext context) {
    if (_working || _phase.now == FamilyPhase.starting) {
      return Column(children: [
        const Spacer(),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Column(
              children: [
                Text(
                  "",
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: context.theme.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "home status detail progress".i18n + "\n\n",
                  style: TextStyle(
                      fontSize: 18, color: context.theme.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            )),
        const SizedBox(height: 72),
      ]);
    } else {
      return Container();
    }
  }

  Future<void> _showCommandDialog(BuildContext context) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return CommandDialog();
        });
  }
}
