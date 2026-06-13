import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatapp_clone/colors.dart';
import 'package:whatapp_clone/common/enums/message_enum.dart';
import 'package:whatapp_clone/common/providers/message_reply_provider.dart';
import 'package:whatapp_clone/common/utils/utils.dart';
import 'package:whatapp_clone/features/chat/controller/chat_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:whatapp_clone/features/chat/widgets/message_reply_preview.dart';

class BottomChatField extends ConsumerStatefulWidget {
  final String recieverUserId;

  const BottomChatField({super.key, required this.recieverUserId});

  @override
  ConsumerState<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends ConsumerState<BottomChatField> {
  bool isShowSendButton = false;
  bool isShowEmojiContainer = false;
  bool isRecordInit = false;
  bool isRecording = false;
  FocusNode focusNode = FocusNode();
  final TextEditingController _messageController = TextEditingController();
  FlutterSoundRecorder? _flutterSoundRecorder;

  @override
  void initState() {
    super.initState();
    // _flutterSound
    openAudio();

    _flutterSoundRecorder = FlutterSoundRecorder();
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic permission not allows');
    }
    await _flutterSoundRecorder!.openRecorder();
    isRecordInit = true;
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void showKeyboard() => focusNode.requestFocus();
  void hideKeyboard() => focusNode.unfocus();

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer) {
      hideEmojiContainer();
      showKeyboard();
    } else {
      showEmojiContainer();
      hideKeyboard();
    }
  }

  void sendFileMessage(XFile file, MessageEnum messageEnum) {
    ref
        .read(chatControllerProvider)
        .sendFileMessage(context, file, widget.recieverUserId, messageEnum);
  }

  void selectImage() async {
    XFile? image = await pickImageFromGallery(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectGif() async {
    // GiphyGif? gif = await pickGIF(context);
    // if (gif != null) {
    //   ref
    //       .read(chatControllerProvider)
    //       .sendGifMessage(context, gif.url, widget.recieverUserId);
    // }
  }

  void selectVideo() async {
    XFile? video = await pickVideoFromGallery(context);
    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
  }

  // void stopRecording() {
  //   if (isRecording == false || isRecordInit == false) return;

  // }

  void sendTextMessage() async {
    if (isShowSendButton) {
      debugPrint(_messageController.text.toString());
      ref
          .read(chatControllerProvider)
          .sendTextMessage(
            context,
            _messageController.text.trim(),
            widget.recieverUserId,
          );

      setState(() {
        _messageController.text = "";
      });
    } else {
      var tempDir = await getTemporaryDirectory();

      var path = '${tempDir.path}/flutter_sound.aac';
      if (!isRecordInit) return; //prevents use of recorder before initialize
      if (isRecording) {
        final recordedPath = await _flutterSoundRecorder!.stopRecorder();
        debugPrint("sending...audio");
        if (recordedPath != null) {
          sendFileMessage(XFile(recordedPath), MessageEnum.audio);
        }
      } else {
        await _flutterSoundRecorder!.startRecorder(
          toFile: path,
          codec: Codec.aacADTS,
        );
      }
      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    if (_flutterSoundRecorder != null) {
      _flutterSoundRecorder!.closeRecorder();
      _flutterSoundRecorder = null;
    }
    isRecordInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final messageReply = ref.watch(messageReplyProvider);
    final isShowMessageReply = messageReply != null;

    return Column(
      children: [
        isShowMessageReply ? const MessageReplyPreview() : const SizedBox(),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TextField(
                focusNode: focusNode,
                controller: _messageController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: mobileChatBoxColor,
                  prefixIcon: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              toggleEmojiKeyboardContainer();
                            },
                            icon: Icon(Icons.emoji_emotions),
                            color: Colors.grey,
                          ),
                          IconButton(
                            onPressed: () {
                              selectGif();
                            },
                            icon: Icon(Icons.gif),
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  suffixIcon: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isShowSendButton)
                          IconButton(
                            onPressed: selectImage,
                            icon: Icon(Icons.camera_alt),
                            color: Colors.grey,
                          ),
                        IconButton(
                          onPressed: selectVideo,
                          icon: Icon(Icons.attach_file),
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  hintText: 'Type a message!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(10),
                ),

                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      isShowSendButton = true;
                    });
                  } else {
                    setState(() {
                      isShowSendButton = false;
                    });
                  }
                },
              ),
            ),

            SizedBox(width: 10),
            CircleAvatar(
              backgroundColor: messageColor,
              radius: 25,
              child: isShowSendButton
                  ? GestureDetector(
                      onTap: sendTextMessage,
                      child: Icon(Icons.send, color: Colors.white),
                    )
                  : GestureDetector(
                      onTap: () {
                        sendTextMessage;
                      },
                      child: Icon(
                        isRecording ? Icons.close : Icons.mic,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),

        isShowEmojiContainer
            ? SizedBox(
                height: 280,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    setState(() {
                      _messageController.text =
                          _messageController.text + emoji.emoji;
                    });

                    if (!isShowSendButton) {
                      setState(() {
                        isShowSendButton = true;
                      });
                    }
                  },
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
