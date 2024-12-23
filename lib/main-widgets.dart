import 'package:common/common/navigation.dart';
import 'package:common/common/widget/app.dart';
import 'package:common/common/widget/top_bar.dart';
import 'package:common/core/core.dart';
import 'package:common/family/widget/main_screen.dart';
import 'package:common/modules.dart';
import 'package:common/platform/command/command.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  // Needed for the MethodChannels
  WidgetsFlutterBinding.ensureInitialized();

  await I18nService.loadTranslations();

  final modules = Modules();
  await modules
      .create(ActScreenplay(ActScenario.prod, Flavor.family, PlatformType.iOS));
  modules.start(Markers.start);

  final ws = DevWebsocket();
  Core.register(ws);
  ws.handle();

  final ctrl = Core.get<TopBarController>();
  final nav = NavigationPopObserver();

  runApp(BlokadaApp(
      content: FamilyMainScreen(ctrl: ctrl, nav: nav), isFamily: true));
}

class DevWebsocket {
  var ip = "192.168.1.177";
  //var ip = "192.168.234.104";

  late final command = Core.get<CommandStore>();
  WebSocketChannel? channel;

  handle() async {
    channel = WebSocketChannel.connect(
      // Uri.parse('ws://192.168.1.176:8765'),
      Uri.parse('ws://$ip:8765'),
    );
    channel?.stream.listen((msg) async {
      command.onCommandString(msg, 1);
    });
  }
}
