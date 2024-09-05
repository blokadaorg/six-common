part of '../../model.dart';

enum SupportEvent {
  firstOpen("FIRST_OPEN");

  final String constant;

  const SupportEvent(this.constant);
}

class SupportMessage {
  String text;
  bool isMe;
  DateTime when;

  SupportMessage(this.text, this.when, {required this.isMe});
}
