import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_skonto/core/extensions.dart';
import 'package:radio_skonto/helpers/app_colors.dart';
import 'package:radio_skonto/helpers/constant.dart';
import 'package:radio_skonto/models/podcasts_model.dart';
import 'package:radio_skonto/providers/download_provider.dart';
import 'package:radio_skonto/providers/player_provider.dart';
import 'package:radio_skonto/widgets/download_routed_button.dart';
import 'package:radio_skonto/widgets/like_widget.dart';
import 'package:radio_skonto/widgets/round_button_with_icon.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../helpers/app_text_style.dart';

class VideoPodcastDetailScreen extends StatefulWidget {
  const VideoPodcastDetailScreen({super.key, required this.episode});

  final Episode episode;

  @override
  State<VideoPodcastDetailScreen> createState() => _VideoPodcastDetailScreenState();
}

class _VideoPodcastDetailScreenState extends State<VideoPodcastDetailScreen> {

  late VideoPlayerController _controller;
  late ChewieController chewieController;
  late YoutubePlayerController _youtubeController;
  bool isYoutube = false;

  @override
  void initState() {
    super.initState();

    if (widget.episode.contentData.cards.first.videoUrl.contains('youtube')) {
      isYoutube = true;
    }

    if (isYoutube) {
      String? videoId = YoutubePlayer.convertUrlToId(widget.episode.contentData.cards.first.videoUrl);
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId?? '',
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          //showLiveFullscreenButton: false
        ),
      );
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(
          apiBaseUrl + widget.episode.contentData.cards.first.videoUrl))
        ..initialize().then((_) {
          chewieController = ChewieController(
            videoPlayerController: _controller,
            autoPlay: false,
            //looping: false,
          );
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isFoolScreen = false;
    if (isYoutube) {
      isFoolScreen = _youtubeController.value.isFullScreen;
      if (isFoolScreen == true) {
        Future.delayed(const Duration(milliseconds: 300), () {
          context.read<PlayerProvider>().hideMiniPlayer();
        });
      } else {
       // context.read<PlayerProvider>().showMiniPlayer();
      }
    }
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
        appBar: isFoolScreen ? null : AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
        ),
        backgroundColor: AppColors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              isFoolScreen ? const SizedBox() : 10.hs,
              isFoolScreen ? const SizedBox() : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Padding(padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
                    child: Text(widget.episode.title, style: AppTextStyles.main18bold, maxLines: 2),),
                  ),
                  LikeWidget(onTap: () {}, color: AppColors.red.withAlpha(64))
                ],
              ),
              isFoolScreen ? const SizedBox() : 25.hs,
              isYoutube ?
                  Padding(padding: isFoolScreen ? const EdgeInsets.all(0) : const EdgeInsets.only(left: 20, right: 20),
                    child: YoutubePlayer(
                      key: const ObjectKey(387349384),
                      aspectRatio: width > height ? width/height : height/width,
                      controller: _youtubeController,
                      actionsPadding: const EdgeInsets.only(left: 16.0),
                      bottomActions: [
                        const CurrentPosition(),
                        const SizedBox(width: 10.0),
                        const ProgressBar(isExpanded: true, colors: ProgressBarColors(
                          playedColor: AppColors.red,
                          handleColor: AppColors.red,
                        )),
                        const SizedBox(width: 10.0),
                        const RemainingDuration(),
                        const FullScreenButton(),
                      ],
                    ),
                  ) :
              _controller.value.isInitialized ?
              AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Chewie(
                    controller: chewieController,
                  )

                //VideoPlayer(_controller),
              ) : Container(
                height: 200,
                width: double.infinity,
                color: AppColors.gray,
                child: const Center(
                  child: Icon(Icons.video_camera_back_outlined, size: 50, color: AppColors.black,),
                ),
              ),
              isFoolScreen ? const SizedBox() : SingleChildScrollView(
                child: Padding(
                  padding: isFoolScreen ? const EdgeInsets.all(0) : const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isFoolScreen ? const SizedBox() : 20.hs,
                      isFoolScreen ? const SizedBox() : Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          widget.episode.contentData.cards.isEmpty || widget.episode.contentData.cards.first.allowDownloading == false ?
                          const SizedBox() :
                          DownloadRoutedButtonWidget(size: 50, task: TaskInfo(name: widget.episode.contentData.cards.first.video, link: apiBaseUrl +  widget.episode.contentData.cards.first.video)),
                          10.ws,
                          RoutedButtonWithIconWidget(iconName: 'assets/icons/shared_video.svg',
                            iconColor: AppColors.darkBlack,
                            size: 50,
                            onTap: () {
                              Share.share(apiBaseUrl + widget.episode.contentData.cards.first.video);
                            },
                            color: AppColors.gray, iconSize: 20,
                          ),
                        ],
                      ),
                      20.hs,
                      Text(widget.episode.description, style: AppTextStyles.main14regular),
                      120.hs
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
    );
  }
}