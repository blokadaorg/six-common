import 'package:common/mock/via/mock_family.dart';
import 'package:common/mock/widget/mock_scaffolding.dart';
import 'package:flutter/material.dart';
import 'package:vistraced/via.dart';

import 'entrypoint.dart';
import 'service/I18nService.dart';
import 'common/widget/root.dart';
import 'util/act.dart';
import 'util/di.dart';

@Bootstrap(ViaAct(
  scenario: "production",
  platform: ViaPlatform.ios,
  flavor: "family",
))
void main() async {
  // Needed for the MethodChannels
  WidgetsFlutterBinding.ensureInitialized();

  await I18nService.loadTranslations();

  final entrypoint = Entrypoint();
  entrypoint
      .attach(ActScreenplay(ActScenario.prod, Flavor.family, Platform.ios));

  entrypoint.onStartApp();

  MockModule();
  injector.inject();

  runApp(Root(content: MockScaffoldingWidget()));
}
