import 'package:common/common/widget.dart';
import 'package:common/mock/widget/nav_close_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'edit_profile.dart';
import 'profile_button.dart';

class AddProfileSheet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddProfileSheetState();
}

class AddProfileSheetState extends State<AddProfileSheet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.bgColorCard,
      body: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          backgroundColor: context.theme.shadow.withOpacity(0.4),
          automaticallyImplyLeading: false,
          middle: const Text('Add a profile'),
          trailing: NavCloseButton(onTap: () => Navigator.of(context).pop()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(children: [
            Text("What profile you want to add?",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text("Choose a template to get started.",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
            SizedBox(height: 56),
            ProfileButton(
              onTap: () => _showNameProfileDialog(context, null),
              icon: CupertinoIcons.plus_circle_fill,
              iconColor: Colors.black54,
              name: "Custom",
            ),
            SizedBox(height: 12),
            ProfileButton(
              onTap: () => _next(context),
              icon: CupertinoIcons.person_2_alt,
              iconColor: Colors.blue,
              name: "Parent",
              chevron: false,
            ),
            SizedBox(height: 12),
            ProfileButton(
              onTap: () => _next(context),
              icon: CupertinoIcons.person_solid,
              iconColor: Colors.green,
              name: "Child",
              chevron: false,
            ),
          ]),
        ),
      ),
    );
  }

  _next(BuildContext context) {
    // TODO: add a profile
    Navigator.of(context).pop();
  }

  void _showNameProfileDialog(BuildContext context, String? name) {
    showDefaultDialog(
      context,
      title: Text(name == null ? "New Profile" : "Rename Profile"),
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
            Navigator.of(context).pop();
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
