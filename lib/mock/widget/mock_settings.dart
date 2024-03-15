import 'package:common/common/widget.dart';
import 'package:common/common/widget/family/home/bg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:pinput/pinput.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';

import '../../lock/lock.dart';
import '../../util/di.dart';
import '../../util/trace.dart';
import 'mock_profiles.dart';

class MockSettingsScreen extends StatelessWidget with TraceOrigin {
  MockSettingsScreen({super.key});

  late final _lock = dep<LockStore>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.bgColor,
      body: SuperScaffold(
        appBar: SuperAppBar(
          searchBar: SuperSearchBar(enabled: false),
          backgroundColor: context.theme.panelBackground.withOpacity(0.5),
          largeTitle: SuperLargeTitle(largeTitle: "Settings"),
          previousPageTitle: "Home",
        ),
        body: Container(
          color: context.theme.panelBackground,
          child: Stack(
            children: [
              SettingsList(
                applicationType: ApplicationType.cupertino,
                platform: DevicePlatform.iOS,
                sections: [
                  SettingsSection(
                    tiles: [
                      CustomSettingsTile(
                        child: ClipRRect(
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
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: Text('PRIMARY'),
                    tiles: [
                      SettingsTile.navigation(
                        onPressed: (context) {
                          Navigator.push(
                            context,
                            StandardRoute(
                                builder: (context) =>
                                    const MockProfilesScreen()),
                          );
                        },
                        leading: Icon(CupertinoIcons.profile_circled),
                        title: Text('Profiles'),
                      ),
                      SettingsTile.navigation(
                        leading: Icon(CupertinoIcons.shield),
                        title: Text('Blocking'),
                      ),
                      SettingsTile.navigation(
                        onPressed: (context) {
                          _showPinDialog(
                            context,
                            title: "Change pin",
                            desc: "Enter your new pin",
                            inputValue: "",
                            onConfirm: (String value) {
                              traceAs("tappedChangePin", (parentTrace) async {
                                await _lock.lock(parentTrace, value);
                              });
                            },
                            onRemove: () {
                              traceAs("tappedRemovePin", (parentTrace) async {
                                await _lock.removeLock(parentTrace);
                              });
                            },
                          );
                        },
                        leading: Icon(CupertinoIcons.ellipsis),
                        title: Text('Change pin'),
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: Text('OTHER'),
                    tiles: [
                      SettingsTile.navigation(
                        leading: Icon(CupertinoIcons.return_icon),
                        title: Text('Restore purchase'),
                      ),
                      SettingsTile.navigation(
                        leading: Icon(CupertinoIcons.question_circle),
                        title: Text('Support'),
                      ),
                      SettingsTile.navigation(
                        leading: Icon(CupertinoIcons.person_2),
                        title: Text('About'),
                        description: Center(child: Text("Version 24.1.1")),
                      ),
                    ],
                  ),
                ],
              ),
            ],
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
    content: Column(
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
    actions: [
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
