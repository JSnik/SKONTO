import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:radio_skonto/helpers/app_colors.dart';
import 'package:radio_skonto/helpers/app_text_style.dart';
import 'package:radio_skonto/helpers/singleton.dart';
import 'package:radio_skonto/models/podcasts_model.dart';
import 'package:radio_skonto/widgets/app_cached_network_image.dart';
import 'package:radio_skonto/widgets/errorImageWidget.dart';
import 'package:radio_skonto/widgets/like_widget.dart';
import 'package:radio_skonto/widgets/placeholderImageWidget.dart';

class SmallGridCell extends StatelessWidget {
  const SmallGridCell({super.key, required this.podcast, required this.onTap, required this.onFavoriteTap,});

  final Podcast podcast;
  final Function(Podcast podcast) onTap;
  final Function(Podcast podcast) onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(podcast);
      },
      child: GridTile(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: AppCachedNetworkImage(Singleton.instance.checkIsFoolUrl(podcast.image),
                        height: 96,
                        width: 400,
                        boxFit: BoxFit.cover,
                      ),
                      //Image.network('https://farm4.staticflickr.com/3224/3081748027_0ee3d59fea_z_d.jpg', fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(podcast.title, style: AppTextStyles.main12bold, maxLines: 2, overflow: TextOverflow.ellipsis)),
                        SizedBox( width: 53,
                          child: Text(' ${podcast.episodes.length} ${Singleton.instance.translate('items_title')}', style: AppTextStyles.main12regular),
                        ),
                      ],),
                    const SizedBox(height: 3),
                    //Text(Singleton.instance.translate('residence_title'), style: AppTextStyles.main10regular),
                  ],
                ),
              ),
              Positioned(
                  top: 25,
                  right: 25,
                  child: LikeWidget(
                    color: AppColors.white.withAlpha(192),
                    onTap: () {

                    },)
              )
            ],
          )
      ),
    );
  }
}