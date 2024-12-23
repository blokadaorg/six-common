import 'package:common/common/widget/color.dart';
import 'package:flutter/material.dart';

class TwoLetterIconWidget extends StatelessWidget {
  final String name;
  final Color? colorOverride;
  final bool big;

  const TwoLetterIconWidget(
      {super.key, required this.name, this.colorOverride, this.big = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: ColorFiltered(
        colorFilter:
            ColorFilter.mode(colorOverride ?? genColor(name), BlendMode.color),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[300]!, Colors.grey[600]!],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
            ),
          ),
          child: SizedBox(
            width: big ? 60 : 40,
            height: big ? 60 : 40,
            child: Center(
              child: Text(
                name.substring(0, 2).toUpperCase().trim(),
                style: TextStyle(
                  fontSize: big ? 24 : 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
