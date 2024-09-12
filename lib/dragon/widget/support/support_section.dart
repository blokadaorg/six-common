import 'package:chatview/chatview.dart';
import 'package:common/common/model.dart';
import 'package:common/common/widget/theme.dart';
import 'package:common/dragon/support/controller.dart';
import 'package:common/dragon/widget/navigation.dart';
import 'package:common/dragon/widget/support/convert.dart';
import 'package:common/util/di.dart';
import 'package:flutter/material.dart';

class SupportSection extends StatefulWidget {
  const SupportSection({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SupportSectionState();
}

class SupportSectionState extends State<SupportSection> {
  late final _controller = dep<SupportController>();

  //final List<types.Message> _messages = [];

  final _me = ChatUser(id: "1", name: "Me");
  final _notMe = ChatUser(
    id: "2",
    name: "Blocka Bot",
    profilePhoto: "assets/images/appicon.png",
    imageType: ImageType.asset,
  );

  late final _chatController = ChatController(
    initialMessageList: _convertMessages(_controller.messages),
    scrollController: ScrollController(),
    currentUser: _me,
    otherUsers: [_notMe],
  );

  @override
  void initState() {
    super.initState();
    _controller.onChange = () {
      _chatController
          .addMessage(_controller.messages.last.toMessage(_me, _notMe));
    };
    _controller.loadOrInit();
    //_refresh();
  }

  _refresh() {
    setState(() {
      // _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: 16.0, right: 16.0, top: getTopPadding(context), bottom: 32.0),
      child: ChatView(
        chatController: _chatController,
        chatViewState: ChatViewState.hasMessages,
        onSendTap: _handleSendPressed,
        featureActiveConfig: FeatureActiveConfig(
          enableReactionPopup: false,
          enableOtherUserProfileAvatar: true,
          enableDoubleTapToLike: false,
          enableSwipeToReply: false,
          enableReplySnackBar: false,
        ),
        sendMessageConfig: SendMessageConfiguration(
          enableCameraImagePicker: false,
          enableGalleryImagePicker: false,
          allowRecordingVoice: false,
          //sendButtonIcon: Icon(Icons.send),
        ),
        reactionPopupConfig: null,
        chatBackgroundConfig: ChatBackgroundConfiguration(
          backgroundColor: context.theme.bgColor,
        ),
      ),
    );
  }

  // void _addMessage(types.Message message) {
  //   setState(() {
  //     _messages.insert(0, message);
  //   });
  // }

  void _handleSendPressed(
      String message, ReplyMessage replyMessage, MessageType type) {
    // final textMessage = types.TextMessage(
    //   author: _user,
    //   createdAt: DateTime.now().millisecondsSinceEpoch,
    //   id: randomString(),
    //   text: message.text,
    // );
    //
    // _addMessage(textMessage);
    _controller.sendMessage(message);
  }

  List<Message> _convertMessages(List<SupportMessage> messages) {
    return messages.map((e) => e.toMessage(_me, _notMe)).toList();
  }
}
