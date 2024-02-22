import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../widget.dart';

import 'package:chewie/chewie.dart';

class PrivateDnsSheet extends StatefulWidget {
  const PrivateDnsSheet({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PrivateDnsSheetState();
}

class PrivateDnsSheetState extends State<PrivateDnsSheet> {
  late VideoPlayerController _controller;
  late final ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/private_dns.mp4');
    // _controller = VideoPlayerController.networkUrl(
    //     Uri.parse("https://www.fluttercampus.com/video.mp4"));
    chewieController = ChewieController(
      hideControlsTimer: const Duration(seconds: 1),
      showControlsOnInitialize: false,
      showOptions: false,
      allowMuting: false,
      videoPlayerController: _controller,
      aspectRatio: 886 / 1477,
      autoPlay: false,
      looping: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          // Row(
          //   children: [
          //     Expanded(child: Container()),
          //     Text("Cancel", style: TextStyle(color: context.theme.family)),
          //   ],
          // ),
          const SizedBox(height: 24),
          Text("One more thing",
              style: Theme.of(context)
                  .textTheme
                  .displaySmall!
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
                "Activate \"Blokada Family\" in Settings by following the video instructions.",
                softWrap: true,
                textAlign: TextAlign.justify,
                style: TextStyle(color: context.theme.textSecondary)),
          ),
          Spacer(),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SizedBox(
                width: 257,
                height: 430,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: context.theme.bgColor,
                    child: Chewie(controller: chewieController),
                  ),
                ),
              )),

          Spacer(),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MiniCard(
                    onTap: () => {},
                    color: context.theme.family,
                    child: const SizedBox(
                      height: 32,
                      child: Center(
                        child: Text(
                          "Open Settings",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}
