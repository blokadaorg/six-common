import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../widget.dart';

class GuestSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: context.theme.bgColorCard,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Row(
              children: [
                Expanded(child: Container()),
                Text("Cancel", style: TextStyle(color: context.theme.family)),
              ],
            ),
            const SizedBox(height: 48),
            Text("Lockdown mode",
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  Text(
                      "To share this device with your child, enable lockdown mode to filter the content they can access.",
                      textAlign: TextAlign.justify,
                      style: TextStyle(color: context.theme.textSecondary)),
                  const SizedBox(height: 48),
                  const ExplainItemWidget(
                    icon: CupertinoIcons.lock,
                    title: "Lock your device",
                    description:
                        "Once you set the pin code in the next step, Blokada will activate for this device.",
                  ),
                  const SizedBox(height: 24),
                  const ExplainItemWidget(
                    icon: CupertinoIcons.eye_slash,
                    title: "Content filtering",
                    description:
                        "You can unlock Blokada and adjust the filtering settings whenever you like.",
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MiniCard(
                      onTap: () => {},
                      color: context.theme.family,
                      child: const SizedBox(
                        height: 32,
                        child: Center(
                          child: Text(
                            "Continue",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }
}
