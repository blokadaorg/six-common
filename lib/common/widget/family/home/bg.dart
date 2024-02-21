import 'package:common/common/widget.dart';
import 'package:flutter/material.dart';

class FamilyBgWidget extends StatelessWidget {
  final Widget child;

  const FamilyBgWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff4ae5f6),
            Color(0xff3c8cff),
            Color(0xff3c8cff),
          ],
        ),
      ),
      child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.transparent,
                Color(0xffe450cd),
                Color(0xffe450cd),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.transparent,
                  context.theme.bgColorHome1.withOpacity(0.4),
                  context.theme.bgColorHome2,
                  context.theme.bgColorHome2,
                  context.theme.bgColorHome2,
                ],
              ),
            ),
            child: child,
          )));
}
