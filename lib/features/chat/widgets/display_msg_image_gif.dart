// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:whatapp_clone/common/enums/message_enum.dart';
import 'package:whatapp_clone/features/chat/widgets/vide_player_item.dart';

class DisplayMsgImageGif extends StatelessWidget {
  final String message;
  final MessageEnum type;

  const DisplayMsgImageGif({
    super.key,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    bool isPlaying = false;
    AudioPlayer audioPlayer = AudioPlayer();

    // debugPrint(message);
    return type == MessageEnum.text
        ? Text(message, style: const TextStyle(fontSize: 16))
        : type == MessageEnum.video
        ? VideoPlayerItem(videoUrl: message)
        : type == MessageEnum.audio
        ? StatefulBuilder(
            builder: (context, setState) {
              return IconButton(
                constraints: BoxConstraints(minWidth: 100),
                onPressed: () async {
                  if (isPlaying) {
                    await audioPlayer.pause();
                    setState(() {
                      isPlaying = false;
                    });
                  } else {
                    await audioPlayer.play(UrlSource(message));
                    setState(() {
                      isPlaying = true;
                    });
                  }
                },
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              );
            },
          )
        : type == MessageEnum.gif
        ? CachedNetworkImage(imageUrl: message)
        : CachedNetworkImage(imageUrl: message);

    // : Container(
    //     width: 200,
    //     height: 200,
    //     decoration: BoxDecoration(
    //       image: DecorationImage(
    //         fit: BoxFit.cover,
    //         image: CachedNetworkImageProvider(message),
    //       ),
    //     ),
    //   );
  }
}
