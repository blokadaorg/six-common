import 'package:common/core/core.dart';
import 'package:flutter/material.dart';

const _tabBarHeight = 80.0;

class TapBarCompensation extends StatelessWidget {
  const TapBarCompensation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Core.act.isFamily) return Container();
    return SizedBox(height: context.tabBarHeight);
  }
}

extension BuildContextExt on BuildContext {
  double get tabBarHeight =>
      Core.act.isFamily ? 0 : (isKeyboardOpened ? 0 : _tabBarHeight);
  bool get isKeyboardOpened => MediaQuery.of(this).viewInsets.bottom > 0;
}
