import 'package:common/common/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileButton extends StatefulWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final Color iconColor;
  final String name;
  final bool chevron;

  const ProfileButton(
      {Key? key,
      this.onTap,
      required this.icon,
      required this.iconColor,
      required this.name,
      this.chevron = true})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ProfileButtonState();
}

class ProfileButtonState extends State<ProfileButton> {
  @override
  Widget build(BuildContext context) {
    return Touch(
      onTap: widget.onTap,
      decorationBuilder: (value) {
        return BoxDecoration(
          color: context.theme.bgMiniCard.withOpacity(value),
          borderRadius: BorderRadius.circular(36),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.theme.divider.withOpacity(0.05),
          borderRadius: BorderRadius.circular(36),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                widget.icon,
                color: widget.iconColor,
              ),
              Text(
                widget.name,
                style: TextStyle(
                  color: context.theme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
              widget.chevron
                  ? Icon(
                      CupertinoIcons.chevron_right,
                      color: context.theme.textSecondary,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
