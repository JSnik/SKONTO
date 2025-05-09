import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_skonto/helpers/app_colors.dart';
import 'package:radio_skonto/helpers/singleton.dart';
import 'package:radio_skonto/models/main_screen_data.dart';
import 'package:radio_skonto/providers/main_screen_provider.dart';
import 'package:radio_skonto/widgets/app_cached_network_image.dart';

class OneImageBannerWidget extends StatelessWidget {
  const OneImageBannerWidget({required this.banners, super.key, required this.padding, this.bannerNumberToShow, this.topAndBottomPadding});

  final List<AdBanner> banners;
  final double padding;
  final int? bannerNumberToShow;
  final double? topAndBottomPadding;


  @override
  Widget build(BuildContext context) {
    List<AdBanner> bannerList = getOneImageBanners(banners, context);

    return bannerList.isEmpty ?
    const SizedBox() :
    Container(
      //height: 170,
      //margin: EdgeInsets.only(left: padding, right: padding, bottom: topAndBottomPadding?? 20, top: topAndBottomPadding?? 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: padding, right: padding, bottom: topAndBottomPadding?? 20, top: topAndBottomPadding?? 24),
        child: bannerNumberToShow == null ?
        Column(
          children: [
            ...bannerList.map((b) => Padding(padding: const EdgeInsets.only(bottom: 15),
              child: GestureDetector(
                onTap: () {
                  if (b.link != '') {
                    _openLink(b.link!, context, b.id);
                  }
                },
                child: AppCachedNetworkImage(
                  Singleton.instance.checkIsFoolUrl(b.image),
                  width: double.infinity,
                  boxFit: BoxFit.fitWidth,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(0),
                    boxShadow: [
                      //App.appBoxShadow
                    ],
                  ),
                ),
              ),
            ))
          ],
        ) :
        bannerNumberToShow! > bannerList.length - 1  ? const SizedBox() :
        GestureDetector(
          onTap: () {
            if (bannerList[bannerNumberToShow!].link != '') {
              _openLink(bannerList[bannerNumberToShow!].link!, context, bannerList[bannerNumberToShow!].id);
            }
          },
          child: AppCachedNetworkImage(
            Singleton.instance.checkIsFoolUrl(bannerList[bannerNumberToShow!].image),
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(0),
              boxShadow: [
                //App.appBoxShadow
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<AdBanner> getOneImageBanners(List<AdBanner> banners, BuildContext context) {
    List<AdBanner> bannersToShow = [];
    List<int> ids = [];
    if (banners.isNotEmpty) {
      for (AdBanner banner in banners) {
        if (banner.type == 'banner_single_image_slide_mobile') {
          bannersToShow.add(banner);
          ids.add(banner.id);
        }
      }
    }
    if (ids.isNotEmpty) {
      final provider = Provider.of<MainScreenProvider>(context, listen: false);
      if (provider.needSendStatisticOneImageBannerWidget == true) {
        provider.needSendStatisticOneImageBannerWidget = false;
        provider.sendEventBannerShown('banner', ids);
      }
    }
    return bannersToShow;
  }

  void _openLink(String link, BuildContext context, int bannerId) async {
    Provider.of<MainScreenProvider>(context, listen: false).sendEventBannerClick('banner', bannerId);
    Singleton.instance.openUrl(link, context);
  }
}