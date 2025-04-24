import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:radio_skonto/helpers/singleton.dart';
import 'package:radio_skonto/widgets/errorImageWidget.dart';
import 'package:radio_skonto/widgets/placeholderImageWidget.dart';

class AppCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxDecoration? decoration;
  final BoxFit? boxFit;
  final double? opacity;
  final Color? colorFilter;

  const AppCachedNetworkImage(
      this.imageUrl, {
        super.key,
        required this.width,
        required this.height,
        this.decoration,
        this.boxFit,
        this.opacity,
        this.colorFilter,
      });

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: opacity == null ? 1.0 : opacity!,
      child:

      // Image.network(imageUrl,
      //   frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
      //     // final image = DecorationImage(
      //     //     image: imageProvider,
      //     //     colorFilter: ColorFilter.mode(colorFilter?? Colors.transparent, BlendMode.color),
      //     //     fit: boxFit ?? BoxFit.fitWidth
      //     // );
      //     return Container(
      //       width: width,
      //       height: height,
      //       child: child,
      //       // decoration:
      //       // decoration?.copyWith(image: child) ?? BoxDecoration(image: image),
      //     );
      //   },
      //   loadingBuilder: (context, wid, im) {
      //     return PlaceholderImageWidget(size: width);
      //   },
      //   errorBuilder: (context, wid, im) {
      //     return ErrorImageWidget(height: height, width: width);
      //   },
      //   fit: boxFit ?? BoxFit.fill,
      // ),

      CachedNetworkImage(
        //useOldImageOnUrlChange: true,
        imageUrl: imageUrl,
        // memCacheWidth: 45,
        // memCacheHeight: 60,
        // maxHeightDiskCache: 60,
        // maxWidthDiskCache: 45,
        cacheManager: Singleton.instance.cacheManager,
        //CacheManager(Config(imageUrl, stalePeriod: const Duration(days: 10), maxNrOfCacheObjects: 100,)),
        // memCacheHeight: 300,
        // memCacheWidth: 300,
        fit: boxFit ?? BoxFit.fill,
        fadeInDuration : const Duration(milliseconds: 0),
        fadeOutDuration: const Duration(milliseconds: 0),
        imageBuilder: (context, imageProvider) {
          final image = DecorationImage(
              image: imageProvider,
              colorFilter: ColorFilter.mode(colorFilter?? Colors.transparent, BlendMode.color),
              fit: boxFit ?? BoxFit.fitWidth
          );
          return Container(
            width: width,
            height: height,
            decoration:
            decoration?.copyWith(image: image) ?? BoxDecoration(image: image),
          );
        },
        placeholder: (context, url) => PlaceholderImageWidget(size: width),
        errorWidget: (context, url, error) => ErrorImageWidget(height: height, width: width),
      ),
    );
  }
}
