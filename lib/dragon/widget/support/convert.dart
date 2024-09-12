import 'package:chatview/chatview.dart';
import 'package:common/common/model.dart';

extension SupportMsgExt on SupportMessage {
  Message toMessage(ChatUser me, ChatUser notMe) {
    return Message(
      sentBy: isMe ? me.id : notMe.id,
      createdAt: when,
      id: when.millisecondsSinceEpoch.toString(),
      message: text,
    );
  }
}

// String randomString() {
//   const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
//   final rnd = Random();
//   final result =
//   List.generate(16, (_) => chars[rnd.nextInt(chars.length)]).join();
//   return result;
// }
