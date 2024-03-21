import 'package:common/common/widget.dart';
import 'package:flutter/material.dart';

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(
        height: 1,
        thickness: 0.5,
        indent: 40,
        color: context.theme.shadow,
      ),
    );
  }
}
