import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:radio_skonto/core/extensions.dart';
import 'package:radio_skonto/helpers/app_colors.dart';
import 'package:radio_skonto/helpers/app_text_style.dart';
import 'package:radio_skonto/helpers/constant.dart';
import 'package:radio_skonto/helpers/singleton.dart';
import 'package:radio_skonto/models/podcasts_model.dart';
import 'package:radio_skonto/widgets/app_cached_network_image.dart';
import 'package:radio_skonto/widgets/like_widget.dart';

class VerticalGridPodcastCell extends StatelessWidget {
  const VerticalGridPodcastCell({super.key, required this.podcast, required this.onItemTap, required this.size});

  final Podcast podcast;
  final Function(Podcast podcast) onItemTap;
  final double size;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {onItemTap(podcast);},
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    App.appBoxShadow
                  ],
                ),
                child: AppCachedNetworkImage(
                  Singleton.instance.checkIsFoolUrl(podcast.image),
                  boxFit: BoxFit.fill,
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: double.infinity),
                  15.hs,
                  Text(podcast.title, style: AppTextStyles.main12bold, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.start,),
                  const SizedBox(height: 20),
                  //Text(mainData.subtitle, style: AppTextStyles.main10regular, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
          ),
          Positioned(
              top: 15,
              right: 33,
              child: LikeWidget(
                color: AppColors.white.withAlpha(192),
                onTap: () {

                },)
          )
        ],
      ),
    );
  }
}