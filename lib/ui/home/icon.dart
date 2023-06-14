import 'package:flutter/material.dart';

import '../theme.dart';
import '../touch.dart';

class HomeIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const HomeIcon({
    super.key,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<BlokadaTheme>()!;
    return Touch(
      onTap: onTap,
      maxValue: 0.4,
      decorationBuilder: (value) {
        return BoxDecoration(
          shape: BoxShape.circle,
          color: theme.bgMiniCard.withOpacity(value),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: theme.textPrimary, size: 24),
      ),
    );
  }
}
