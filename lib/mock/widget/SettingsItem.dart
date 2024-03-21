import 'package:common/common/widget.dart';
import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const SettingsItem(
      {super.key, required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Touch(
      onTap: onTap,
      decorationBuilder: (value) => BoxDecoration(
        color: context.theme.shadow.withOpacity(value),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: context.theme.divider),
            SizedBox(width: 12),
            Text(text, style: TextStyle(fontSize: 16)),
            Spacer(),
            Icon(Icons.chevron_right, size: 24, color: context.theme.divider),
          ],
        ),
      ),
    );
  }
}
