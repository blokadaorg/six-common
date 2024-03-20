import 'package:common/family/family.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vistraced/via.dart';
import 'package:unique_names_generator/unique_names_generator.dart' as names;

import '../../../../journal/journal.dart';
import '../../../../mock/widget/nav_close_button.dart';
import '../../../../stage/channel.pg.dart';
import '../../../../util/di.dart';
import '../../../../util/trace.dart';
import '../../../widget.dart';

part 'add_device_sheet.g.dart';

final _generator = names.UniqueNamesGenerator(
  config: names.Config(
    length: 1,
    seperator: " ",
    style: names.Style.capital,
    dictionaries: [names.animals],
  ),
);

class AddDeviceSheet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _$AddDeviceSheetState();
}

@Injected(onlyVia: true, immediate: true)
class AddDeviceSheetState extends State<AddDeviceSheet> with TraceOrigin {
  late final _modal = Via.as<StageModal?>()..also(dismissOnClose);
  late final _family = dep<FamilyStore>();
  late final _journal = dep<JournalStore>();

  bool _showQr = false; // The widget would stutter animation, show async

  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _generator.generate());

    _ctrl.addListener(() => setState(() {
          traceAs("mockedStart", (trace) async {
            _family.setWaitingForDevice(trace, _ctrl.text);
          });
        }));

    traceAs("addDevice", (trace) async {
      _family.setWaitingForDevice(trace, _ctrl.text);
      _journal.setFrequentRefresh(trace, true);
    });
    _family.deviceFound = () {
      // bug: will not stop refreshing often when dismissed sheet
      close();
    };
  }

  close() {
    traceAs("closeAddDevice", (trace) async {
      Navigator.of(context).pop();
      _journal.setFrequentRefresh(trace, false);
    });
  }

  dismissOnClose() {
    // if (_modal.now == null) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showQr) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() => _showQr = true);
      });
    }

    return Scaffold(
      backgroundColor: context.theme.bgColorCard,
      body: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: context.theme.shadow.withOpacity(0.4),
          automaticallyImplyLeading: false,
          middle: const Text('Add a device'),
          trailing: NavCloseButton(onTap: () => close()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(children: [
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  Text(
                      "Scan the QR code below with the device you want to add to your family. This screen will close once the device is detected.",
                      softWrap: true,
                      textAlign: TextAlign.justify,
                      style: TextStyle(color: context.theme.textSecondary)),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      // Icon(CupertinoIcons.device_phone_portrait,
                      //     color: context.theme.family),
                      // const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Set device name",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Material(
                              child: TextField(
                                controller: _ctrl,
                                style: TextStyle(
                                    color: context.theme.textPrimary,
                                    fontSize: 16),
                                decoration: InputDecoration(
                                  isDense: true,
                                  filled: true,
                                  fillColor: context.theme.bgColorCard,
                                  focusColor: context.theme.bgColorCard,
                                  hoverColor: context.theme.bgColorCard,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 8),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: context.theme.divider
                                            .withOpacity(0.05),
                                        width: 2.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: context.theme.divider
                                            .withOpacity(0.05),
                                        width: 2.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Text("- or -",
                  //     style: TextStyle(
                  //         color: context.theme.textSecondary, fontSize: 16)),
                  // const SizedBox(height: 12),
                  // Row(
                  //   children: [
                  //     // Icon(CupertinoIcons.lock_open,
                  //     //     color: context.theme.family),
                  //     // const SizedBox(width: 12),
                  //     Expanded(
                  //       child: MiniCard(
                  //         //onTap: _handleCtaTap(),
                  //         color: context.theme.family,
                  //         child: SizedBox(
                  //           height: 32,
                  //           child: Center(
                  //             child: Text(
                  //               "Use this device",
                  //               style: const TextStyle(
                  //                   color: Colors.white,
                  //                   fontWeight: FontWeight.w600),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            _showQr
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: context.theme.divider.withOpacity(0.05),
                              width: 2,
                            )),
                        child: QrImageView(
                          data: _generateLink(_ctrl.text),
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                    ],
                  )
                : const SizedBox(height: 200),
            const SizedBox(height: 80),
            const CupertinoActivityIndicator(),
          ]),
        ),
      ),
    );
  }

  String _generateLink(String name) {
    return _family.onboardLinkTemplate.replaceAll("NAME", name.urlEncode);
  }
}
