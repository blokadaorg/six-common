import 'package:common/mock/via/mock_family.dart';
import 'package:common/mock/widget/mock_scaffolding.dart';
import 'package:common/util/trace.dart';
import 'package:flutter/material.dart';
import 'package:vistraced/via.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'command/command.dart';
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

  DevWebsocket().handle();

  runApp(Root(content: MockScaffoldingWidget()));
}

class DevWebsocket with TraceOrigin {
  late final command = dep<CommandStore>();
  late final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.1.176:8765'),
  );

  handle() async {
    channel.stream.listen((msg) async {
      traceAs("devwebsocket", (trace) => command.onCommandString(trace, msg));
    });
  }
}
