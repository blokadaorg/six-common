import 'package:common/family/family.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vistraced/via.dart';

import '../../../../stage/channel.pg.dart';
import '../../../widget.dart';

part 'add_device_sheet.g.dart';

class AddDeviceSheet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _$AddDeviceSheetState();
}

@Injected(onlyVia: true, immediate: true)
class AddDeviceSheetState extends State<AddDeviceSheet> {
  late final _modal = Via.as<StageModal?>();

  bool _showQr = false; // The widget would stutter animation, show async

  @override
  Widget build(BuildContext context) {
    if (!_showQr) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() => _showQr = true);
      });
    }

    return Scaffold(
      body: Container(
        color: context.theme.bgColorCard,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _modal.set(StageModal.lock);
                  },
                  child: Text("Use this device",
                      style: TextStyle(color: context.theme.family)),
                ),
                Expanded(child: Container()),
                Text("Cancel", style: TextStyle(color: context.theme.family)),
              ],
            ),
            const SizedBox(height: 42),
            Text("Add a device",
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(fontWeight: FontWeight.w700)),
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
                                controller: TextEditingController(text: "Crab"),
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
                ? Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: context.theme.divider.withOpacity(0.05),
                          width: 2,
                        )),
                    child: QrImageView(
                      data: familyLinkBase + linkTemplate,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  )
                : const SizedBox(height: 200),
            const SizedBox(height: 80),
            const CupertinoActivityIndicator(),
          ]),
        ),
      ),
    );
  }
}
