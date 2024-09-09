import 'dart:math';

import 'package:common/command/command.dart';
import 'package:common/common/model.dart';
import 'package:common/dragon/support/api.dart';
import 'package:common/util/async.dart';
import 'package:common/util/di.dart';
import 'package:common/util/trace.dart';

class SupportController with TraceOrigin {
  late final _api = dep<SupportApi>();
  late final _command = dep<CommandStore>();

  String language = "en";
  String? sessionId;

  List<SupportMessage> messages = [];

  Function onChange = () {};

  loadOrInit() async {
    // TODO: loading existing session, and persistence of msgs
    // TODO: figure out language

    sendMessage(null);
  }

  sendMessage(String? message) async {
    if (message?.startsWith("cc") ?? false) await _handleCommand(message!);

    try {
      if (message != null) _addMyMessage(message);

      if (sessionId == null) {
        final id = _newSession();
        final hi = await _api.sendEvent(id, language, SupportEvent.firstOpen);
        sessionId = id;
        _addMessage(hi);
      }

      if (message != null) {
        final msg = await _api.sendMessage(sessionId!, language, message);
        _addMessage(msg);
      }
    } catch (e) {
      print("Error sending chat message");
      print(e);
      await sleepAsync(const Duration(milliseconds: 500));
      _addErrorMessage();
    }
  }

  _addMyMessage(String msg) {
    messages.add(SupportMessage(msg, DateTime.now(), isMe: true));
    onChange();
  }

  _addMessage(JsonSupportMessage msg) {
    messages.add(SupportMessage(msg.message, DateTime.now(), isMe: false));
    onChange();
  }

  _addErrorMessage({String? error}) {
    messages.add(SupportMessage(
      error ?? "Sorry did not understand, can you repeat?",
      DateTime.now(),
      isMe: false,
    ));
    onChange();
  }

  String _newSession() {
    // Taken from web app
    // Math.random().toString(36).substring(2, 15)

    return Random().nextDouble().toStringAsFixed(15).substring(2, 15);
  }

  _handleCommand(String message) async {
    try {
      await _command.onCommand(message);
    } catch (e) {
      print("Error handling command");
      print(e);
      await sleepAsync(const Duration(milliseconds: 500));
      _addErrorMessage(error: e.toString());
    }
  }
}
