import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoURL;
  const VideoPlayerItem({super.key, required this.videoURL});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late CachedVideoPlayerController controller;
  bool isPlay = false;
  @override
  void initState() {
    super.initState();
    controller = CachedVideoPlayerController.network(widget.videoURL)
      ..initialize().then((value) {
        controller.setVolume(1);
      });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(children: [
        CachedVideoPlayer(controller),
        Align(
            alignment: Alignment.center,
            child: IconButton(
                onPressed: () {
                  if (isPlay) {
                    controller.pause();
                  }
                  controller.play();
                  setState(() {
                    isPlay = !isPlay;
                  });
                },
                icon: isPlay
                    ? const Icon(Icons.pause_circle)
                    : const Icon(Icons.play_circle))),
      ]),
    );
  }
}
