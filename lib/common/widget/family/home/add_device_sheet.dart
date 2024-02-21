import 'package:common/family/family.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../widget.dart';

class AddDeviceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Row(
            children: [
              Expanded(child: Container()),
              Text("Cancel", style: TextStyle(color: context.theme.family)),
            ],
          ),
          const SizedBox(height: 48),
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
                const SizedBox(height: 48),
                Row(
                  children: [
                    Icon(CupertinoIcons.device_phone_portrait,
                        color: context.theme.family),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Set device name",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Material(
                            child: TextField(
                              controller: TextEditingController(text: "Alva"),
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
                const SizedBox(height: 24),
              ],
            ),
          ),
          const SizedBox(height: 32),
          QrImageView(
            data: familyLinkBase + linkTemplate,
            version: QrVersions.auto,
            size: 200.0,
          ),
          const SizedBox(height: 48),
          const CupertinoActivityIndicator(),
        ]),
      ),
    );
  }
}
