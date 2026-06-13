// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerItem({super.key, required this.videoUrl});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late CachedVideoPlayerPlus cachedVideoPlayerPlus;
  bool isPlay = false;

  @override
  void dispose() {
    cachedVideoPlayerPlus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    cachedVideoPlayerPlus = CachedVideoPlayerPlus.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    cachedVideoPlayerPlus.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return cachedVideoPlayerPlus.isInitialized
        ? AspectRatio(
            aspectRatio: cachedVideoPlayerPlus.controller.value.aspectRatio,
            child: Stack(
              children: [
                VideoPlayer(cachedVideoPlayerPlus.controller),
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    onPressed: () {
                      if (isPlay) {
                        cachedVideoPlayerPlus.controller.pause();
                        setState(() {
                          isPlay = false;
                        });
                      } else {
                        cachedVideoPlayerPlus.controller.play();
                        setState(() {
                          isPlay = true;
                        });
                      }
                    },
                    icon: Icon(isPlay ? Icons.pause : Icons.play_arrow),
                  ),
                ),
              ],
            ),
          )
        : const CircularProgressIndicator();
  }
}
