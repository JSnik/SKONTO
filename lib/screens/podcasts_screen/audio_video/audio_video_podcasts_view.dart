import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_skonto/core/extensions.dart';
import 'package:radio_skonto/helpers/api_helper.dart';
import 'package:radio_skonto/helpers/app_colors.dart';
import 'package:radio_skonto/helpers/app_text_style.dart';
import 'package:radio_skonto/helpers/singleton.dart';
import 'package:radio_skonto/main.dart';
import 'package:radio_skonto/models/podcasts_model.dart';
import 'package:radio_skonto/providers/player_provider.dart';
import 'package:radio_skonto/providers/podcasts_provider.dart';
import 'package:radio_skonto/screens/home_screen/ad/one_image_banner_widget.dart';
import 'package:radio_skonto/screens/podcasts_screen/audio_video/podcast_horisontal_cell.dart';
import 'package:radio_skonto/screens/podcasts_screen/audio_video/vertical_grid_podcast_cell.dart';
import 'package:radio_skonto/screens/podcasts_screen/podcasts_detail.dart';
import 'package:radio_skonto/screens/podcasts_screen/small_cell.dart';
import 'package:radio_skonto/widgets/progress_indicator_widget.dart';
import 'package:radio_skonto/widgets/round_button_with_icon.dart';

class PodcastsWidget extends StatelessWidget {
  const PodcastsWidget({super.key, required this.type, required this.controller});

  final PodcastType type;
  final ScrollController controller;
  static const leftAndRightPadding = 24.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: AppColors.white,
      body: ChangeNotifierProvider.value(
        value: Provider.of<PodcastsProvider>(context),
          child: Consumer<PodcastsProvider>(builder: (context, podcastsProvider, _) {
            ResponseState loadingState = ResponseState.stateFirsLoad;
            late Podcasts currentPodcasts;
            if (type == PodcastType.audio) {
              loadingState = podcastsProvider.getAudioPodcastsResponseState;
              currentPodcasts = podcastsProvider.audioPodcasts;
            }
            if (type == PodcastType.video) {
              loadingState = podcastsProvider.getVideoPodcastsResponseState;
              currentPodcasts = podcastsProvider.videoPodcasts;
            }
            bool isFirstSectionHasData = false;
            if (currentPodcasts.data.isNotEmpty) {
              isFirstSectionHasData =
              currentPodcasts.data.first.podcasts != null &&
                  currentPodcasts.data.first.podcasts!.isNotEmpty ? true : false;
            }

            List<Widget> secondSectionCells = getSecondSectionsCell(currentPodcasts, context);

            return loadingState == ResponseState.stateLoading ?
            AppProgressIndicatorWidget(
              responseState: loadingState,
              onRefresh: () {
                if (type == PodcastType.audio) {
                  podcastsProvider.getAudioPodcasts(false);
                }
                if (type == PodcastType.video) {
                  podcastsProvider.getVideoPodcasts(false);
                }
                if (type == PodcastType.interview) {
                  podcastsProvider.getInterviewPodcasts(false);
                }
              },
            ) :
            Container(
              color: Colors.transparent,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 5),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        isFirstSectionHasData ?
                        Padding(padding: const EdgeInsets.only(left: leftAndRightPadding),
                          child: Text(currentPodcasts.data.first.name, style: AppTextStyles.main16bold),
                        ) : const SizedBox(),
                        isFirstSectionHasData ?
                        RawScrollbar(
                            controller: controller,
                            padding: const EdgeInsets.only(left: leftAndRightPadding, right: leftAndRightPadding),
                            trackVisibility: true,
                            thumbVisibility: true,
                            trackColor: AppColors.gray,
                            thumbColor: AppColors.black,
                            trackRadius: const Radius.circular(5),
                            radius: const Radius.circular(5),
                            thickness: 5,
                            child: SizedBox(
                              height: 298,
                              child: ListView.builder(
                                  controller: controller,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount:  currentPodcasts.data.first.podcasts!.length,
                                  itemBuilder: (context, index) {
                                    return PodcastHorizontalCell(
                                        podcast: currentPodcasts.data.first.podcasts![index],
                                        onItemTap: (podcast) {
                                          context.read<PlayerProvider>().hideNavigationBar();
                                          Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => PodcastDetailScreen(podcast: podcast),
                                              fullscreenDialog: true
                                          ));
                                        },
                                        index: index);
                                  }
                              ),
                            )
                        ) :
                        const SizedBox(),
                        Padding(padding: const EdgeInsets.only(top: 10),
                            child: OneImageBannerWidget(banners: currentPodcasts.banners, padding: 0, bannerNumberToShow: 0,)
                        ),
                        secondSectionCells.isNotEmpty ?
                        Padding(padding: const EdgeInsets.only(left: leftAndRightPadding, top: 10, bottom: 10),
                          child: Text(currentPodcasts.data[1].name, style: AppTextStyles.main16bold),
                        ) : const SizedBox(),
                        secondSectionCells.isNotEmpty ?
                        SizedBox(width: double.infinity,
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 29,
                            runSpacing: 15.0, // gap between lines
                            children: secondSectionCells,
                          ),
                        ) : const SizedBox(),
                        const SizedBox(height: 100)
                      ],),
                  ),
                  Positioned(right: 15, top: 5,
                    child: RoutedButtonWithIconWidget(iconName: 'assets/icons/filters_icon.svg',
                    iconColor: AppColors.darkBlack,
                    size: 50,
                    onTap: () {
                      Singleton.instance.isMainMenu = false;
                      scaffoldKey.currentState?.openEndDrawer();
                    },
                    color: AppColors.gray, iconSize: 20,),
                  )
                ],
              ),
            );
          })
      ));
  }

  List<Widget> getSecondSectionsCell(Podcasts currentPodcasts, BuildContext context) {
    List<Widget> cellList = [];
    const double lrPadding = 19.0;
    double cellSize = (MediaQuery.of(context).size.width - lrPadding* 3) / 2;
    int bannerCounter = 1;
    int bannerSeparatorCounter = 0;

    if (currentPodcasts.data.length > 1 &&
    currentPodcasts.data[1].podcasts != null &&
    currentPodcasts.data[1].podcasts!.isNotEmpty) {
      for (var i = 0; i < currentPodcasts.data[1].podcasts!.length; i++) {
        Podcast p = currentPodcasts.data[1].podcasts![i];
        cellList.add(SizedBox(
          width: cellSize,
          child: VerticalGridPodcastCell(
              podcast: p,
              onItemTap: (podcast) {
                context.read<PlayerProvider>().hideNavigationBar();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PodcastDetailScreen(podcast: podcast),
                    fullscreenDialog: true
                ));
              },
              size: cellSize
          ),
        ));

        bannerSeparatorCounter ++;
        if (bannerSeparatorCounter == 4) {
          bannerSeparatorCounter = 0;
          if (currentPodcasts.banners.isNotEmpty && currentPodcasts.banners.length - 1 >= bannerCounter) {
            cellList.add(Padding(padding: const EdgeInsets.only(top: 0),
                child: OneImageBannerWidget(banners: currentPodcasts.banners,
                  padding: 0,
                  bannerNumberToShow: bannerCounter,
                  topAndBottomPadding: 10,)
            ));
          }
          bannerCounter ++;
        }
      }
    }
    final isEven = cellList.length.isEven;
    if (isEven == false) {
      cellList.add(SizedBox(width: cellSize));
    }
    return cellList;
  }
}