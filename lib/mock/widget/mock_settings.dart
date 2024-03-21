import 'package:common/common/widget.dart';
import 'package:common/common/widget/family/home/bg.dart';
import 'package:common/mock/widget/SettingsDivider.dart';
import 'package:common/mock/widget/SettingsItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../common/widget/family/home/top_bar.dart';
import '../../lock/lock.dart';
import '../../util/di.dart';
import '../../util/trace.dart';
import 'SectionLabel.dart';

class MockSettingsScreen extends StatefulWidget {
  const MockSettingsScreen({super.key});

  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<MockSettingsScreen> with TraceOrigin {
  late final _lock = dep<LockStore>();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(scrollListener);
  }

  void scrollListener() {
    Provider.of<TopBarController>(context, listen: false)
        .updateScrollPos(_scrollController.offset);
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.bgColor,
      body: Container(
        color: context.theme.bgColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: PrimaryScrollController(
            controller: _scrollController,
            child: ListView(
              primary: true,
              children: [
                SizedBox(height: 60),
                Text("Settings",
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge!
                        .copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: 40),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: Stack(
                      children: [
                        FamilyBgWidget(),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: Image.asset(
                                  "assets/images/family-logo.png",
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                  "Your Blokada subscription is active until 2024-04-04",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(color: Colors.white)),
                            ),
                            SizedBox(width: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 48),
                SectionLabel(text: "PRIMARY"),
                MiniCard(
                  child: Column(
                    children: [
                      SettingsItem(
                          icon: CupertinoIcons.shield,
                          text: "Blocking",
                          onTap: () {}),
                      SettingsDivider(),
                      SettingsItem(
                          icon: CupertinoIcons.ellipsis,
                          text: "Change pin",
                          onTap: () {
                            _showPinDialog(
                              context,
                              title: "Change pin",
                              desc: "Enter your new pin",
                              inputValue: "",
                              onConfirm: (String value) {
                                traceAs("tappedChangePin", (parentTrace) async {
                                  Navigator.of(context).pop();
                                  await _lock.lock(parentTrace, value);
                                });
                              },
                              onRemove: () {
                                traceAs("tappedRemovePin", (parentTrace) async {
                                  await _lock.removeLock(parentTrace);
                                });
                              },
                            );
                          }),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                SectionLabel(text: "OTHER"),
                MiniCard(
                  child: Column(
                    children: [
                      SettingsItem(
                          icon: CupertinoIcons.return_icon,
                          text: "Restore purchases",
                          onTap: () {}),
                      SettingsDivider(),
                      SettingsItem(
                          icon: CupertinoIcons.question_circle,
                          text: "Support",
                          onTap: () {}),
                      SettingsDivider(),
                      SettingsItem(
                          icon: CupertinoIcons.person_2,
                          text: "About",
                          onTap: () {}),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Center(
                    child: Text("Version 24.1.1",
                        style: TextStyle(color: context.theme.divider))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showPinDialog(
  BuildContext context, {
  required String title,
  required String desc,
  required String inputValue,
  required Function(String) onConfirm,
  required Function() onRemove,
}) {
  final pinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: TextStyle(
        fontSize: 22, color: context.theme.family, fontWeight: FontWeight.w500),
    decoration: BoxDecoration(
      border: Border.all(color: context.theme.divider),
      borderRadius: BorderRadius.circular(16),
    ),
  );

  showDefaultDialog(
    context,
    title: Text(title),
    content: (context) => Column(
      children: [
        Text(desc),
        const SizedBox(height: 16),
        Material(
          color: Colors.transparent,
          child: Pinput(
            defaultPinTheme: pinTheme,
            onCompleted: (pin) {
              Navigator.of(context).pop();
              onConfirm(pin);
            },
          ),
        ),
      ],
    ),
    actions: (context) => [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text("Cancel"),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          onRemove();
        },
        child: const Text("Remove pin", style: TextStyle(color: Colors.red)),
      ),
    ],
  );
}
