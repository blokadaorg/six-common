import 'package:common/common/widget.dart';
import 'package:common/common/widget/family/home/bg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';

import 'mock_profiles.dart';

class MockSettingsScreen extends StatelessWidget {
  const MockSettingsScreen({super.key});

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
