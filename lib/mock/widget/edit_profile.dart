import 'package:common/common/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';

import '../../common/defaults/filter_decor_defaults.dart';
import '../../common/model.dart';
import '../../util/config.dart';

class EditProfileSheet extends StatefulWidget {
  final String previous;
  final String profile;

  const EditProfileSheet(
      {Key? key, required this.previous, required this.profile})
      : super(key: key);

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
          largeTitle: SuperLargeTitle(largeTitle: widget.profile),
          previousPageTitle: widget.previous,
          actions: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => showInputDialog(context,
                    title: "Edit profile",
                    desc: "Enter a name for this profile.",
                    inputValue: widget.profile, onConfirm: (value) {
                  print("Value: $value");
                }),
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
}
