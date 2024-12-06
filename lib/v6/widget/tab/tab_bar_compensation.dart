import 'package:common/common/widget/theme.dart';
import 'package:flutter/material.dart';

const _tabBarHeight = 80.0;

class TapBarCompensation extends StatelessWidget {
  const TapBarCompensation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (context.theme.isFamily) return Container();
    return const SizedBox(height: _tabBarHeight);
  }
}

extension BuildContextExt on BuildContext {
  double get tabBarHeight => theme.isFamily ? 0 : _tabBarHeight;
}
