import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_media_downloader/flutter_media_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:radio_skonto/helpers/app_colors.dart';
import 'package:radio_skonto/helpers/singleton.dart';
import 'package:radio_skonto/providers/download_provider.dart';
import 'package:radio_skonto/widgets/download_progress_dialog.dart';
import 'package:radio_skonto/widgets/round_button_with_icon.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadRoutedButtonWidget extends StatelessWidget {
   DownloadRoutedButtonWidget({required this.task, super.key, this.size});

  final TaskInfo task;
  final double? size;

   final _flutterMediaDownloaderPlugin = MediaDownload();

  @override
  Widget build(BuildContext context) {
    double s = size == null ? 32 : size!;
    return ChangeNotifierProvider.value(
        value: Provider.of<DownloadProvider>(context),
        child: Consumer<DownloadProvider>(builder: (context, downloadProvider, _) {
          TaskInfo? downloadTask = getDownloadedTask(downloadProvider.tasks, task);
          return isFileExistInSharedPref(task) ?
          RoutedButtonWithIconWidget(
              iconName: 'assets/icons/check_icon.svg',
              iconColor: AppColors.green,
              iconSize: 15,
              size: s,
              onTap: () {
                downloadAudio(task.link?? '', task.name?? 'name', context);
              },
              color: AppColors.gray
          ) :
            downloadTask != null && downloadTask.name == task.name
                && downloadTask.status != DownloadTaskStatus.failed ?
              SizedBox(
                width: s,
                height: s,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.green,
                  backgroundColor: AppColors.gray,
                  value: double.parse(downloadTask.progress.toString()) / 100,
                ),
              )
            :
            RoutedButtonWithIconWidget(
              iconName: 'assets/icons/download_icon.svg',
              iconColor: AppColors.darkBlack,
              iconSize: 15,
              size: s,
              onTap: () {
                downloadAudio(task.link?? '', task.name?? 'name', context);
                //downloadFile(task.link?? '', context);
                // if (downloadTask == null) {
                //   downloadProvider.downloadFile(task, context);
                // } else {
                //   downloadProvider.downloadFile(downloadTask, context);
                // }
              },
              color: AppColors.gray);
    }));
  }

   TaskInfo? getDownloadedTask(List<TaskInfo> tasks, TaskInfo task) {
     TaskInfo? downloadedTask;
    for (TaskInfo t in tasks) {
      if (t.name == task.name) {
        downloadedTask = t;
      }
    }
    return downloadedTask;
  }

  bool isFileExistInSharedPref(TaskInfo task) {
    bool isExist = false;
    List<String> list = Singleton.instance.getDownloadedFileNameListFromSharedPreferences();
    for (String name in list) {
      if (name == task.link) {
        isExist = true;
      }
    }
    return isExist;
  }

   Future<String> getDownloadPath() async {
     if (Platform.isAndroid) {
       return "/storage/emulated/0/Download";
     } else if (Platform.isIOS) {
       Directory directory = await getApplicationDocumentsDirectory();
       return directory.path;
     }
     throw UnsupportedError("");
   }

   Future<void> downloadAudio(String url, String fileName, BuildContext context) async {
     String savePath = '${await getDownloadPath()}/$fileName';

     // File file = File(savePath);
     // if (await file.exists()) {
     //   return;
     // }

     showDialog(
       context: context,
       barrierDismissible: false,
       builder: (context) => DownloadProgressDialog(url: url, savePath: savePath),
     );
   }

   void downloadFile(String url, BuildContext context) async {
     //Permission.storage.request();
     _flutterMediaDownloaderPlugin.downloadMedia(context, url);
     //final uri = Uri.parse('https://thetestdata.com/assets/audio/mp3/thetestdata-sample-mp3-2.mp3');
     //final forcedDownloadUrl = uri.replace(queryParameters: {'Content-Disposition': 'attachment'}).toString();

     // if (await canLaunchUrl(uri)) {
     //   await launchUrl((uri));
     // } else {
     //   throw "Не удалось открыть ссылку";
     // }
   }
}