import 'dart:io' as io;
import 'package:common/json/json.dart';
import 'package:common/mock/widget/mock_scaffolding_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'entrypoint.dart';
import 'service/I18nService.dart';
import 'common/widget/root.dart';
import 'util/act.dart';
import 'util/di.dart';

void main() async {
  // Needed for the MethodChannels
  WidgetsFlutterBinding.ensureInitialized();

  await I18nService.loadTranslations();

  final entrypoint = Entrypoint();
  entrypoint
      .attach(ActScreenplay(ActScenario.prod, Flavor.family, Platform.ios));

  entrypoint.onStartApp();

  runApp(Root(content: MockScaffoldingWidget()));
}
