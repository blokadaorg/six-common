import 'package:common/common/widget.dart';
import 'package:flutter/material.dart';

class FamilyBgWidget extends StatelessWidget {
  const FamilyBgWidget({super.key});

  @override
  Widget build(BuildContext context) => Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff4ae5f6),
            Color(0xff3c8cff),
          ],
        ),
      ),
      child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Color(0xffe450cd),
              ],
            ),
          ),
          child: Container()));
}
