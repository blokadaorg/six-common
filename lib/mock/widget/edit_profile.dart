import 'package:common/common/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';

import '../../common/defaults/filter_decor_defaults.dart';
import '../../common/model.dart';
import '../../util/config.dart';

class EditProfileSheet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditProfileSheetState();
}

class EditProfileSheetState extends State<EditProfileSheet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.bgColorCard,
      body: SuperScaffold(
        appBar: SuperAppBar(
          searchBar: SuperSearchBar(enabled: false),
          backgroundColor: context.theme.panelBackground.withOpacity(0.5),
          largeTitle: SuperLargeTitle(largeTitle: "Child"),
          //previousPageTitle: "Profiles",
          previousPageTitle: "Alva",
          actions: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showNameProfileDialog(context, "Parent"),
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text("Edit",
                      style: TextStyle(color: context.theme.family)),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          color: context.theme.panelBackground,
          child: ListView(padding: EdgeInsets.zero, children: [
            _buildFilter(context, 0, color: const Color(0xFFA9CCFE)),
            _buildFilter(context, 1),
            _buildFilter(context, 2, color: const Color(0xFFF4B1C6)),
            _buildFilter(context, 3, color: const Color(0XFFFDB39C)),
            _buildFilter(context, 4),
            _buildFilter(context, 5),
            _buildFilter(context, 6),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: MiniCard(
                  child: Text("Delete this profile",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ),
            SizedBox(height: 48),
          ]),
        ),
      ),
    );
  }

  Widget _buildFilter(BuildContext context, int index, {Color? color}) {
    final filter = getKnownFilters(cfg.act)[index];
    final texts = filterDecorDefaults
        .firstWhere((it) => it.filterName == filter.filterName);
    return FilterWidget(filter: filter, texts: texts, bgColor: color);
  }

  void _showNameProfileDialog(BuildContext context, String name) {
    showDefaultDialog(
      context,
      title: Text("Edit Profile"),
      content: Column(
        children: [
          const Text("Enter a name for this profile."),
          const SizedBox(height: 16),
          Material(
            child: TextField(
              controller: TextEditingController(text: name),
              decoration: InputDecoration(
                filled: true,
                fillColor: context.theme.panelBackground,
                focusColor: context.theme.panelBackground,
                hoverColor: context.theme.panelBackground,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: context.theme.divider, width: 1.0),
                  borderRadius: BorderRadius.circular(2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: context.theme.divider, width: 1.0),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
          ),
          // const SizedBox(height: 20),
          // Text("Delete this profile",
          //     style: TextStyle(
          //         color: Colors.red,
          //         fontSize: 14,
          //         fontWeight: FontWeight.w500)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Save"),
        ),
      ],
    );
  }
}
