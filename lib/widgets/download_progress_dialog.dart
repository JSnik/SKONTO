import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_media_downloader/flutter_media_downloader.dart';
import 'package:radio_skonto/helpers/app_colors.dart';
import 'package:radio_skonto/helpers/app_text_style.dart';
import 'package:radio_skonto/helpers/singleton.dart';

class DownloadProgressDialog extends StatefulWidget {
  final String url;
  final String savePath;

  DownloadProgressDialog({required this.url, required this.savePath});

  @override
  _DownloadProgressDialogState createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  double _progress = 0.0;
  Dio dio = Dio();
  bool _isDownloading = true;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      await dio.download(widget.url, widget.savePath, onReceiveProgress: (received, total) {
        if (!_isDownloading) return;
        setState(() {
          _progress = received / total;
        });
      });

      if (_isDownloading) {
        Singleton.instance.writeDownloadedFileNameToSharedPreferences(widget.url);
        Navigator.pop(context);
        if (Platform.isIOS) {
          bool saved = await _saveToPublicFolder(widget.savePath);
          if (saved) {
            _deleteFile(widget.savePath);
          }
        }
      }
    } catch (e) {
      if (_isDownloading) {
        Navigator.pop(context);
      }
    }
  }

  Future<bool> _saveToPublicFolder(String filePath) async {
    try {
      if (Platform.isAndroid) {
        await MediaDownload().requestPermission();
      }
      //await MediaDownload().downloadFile(filePath, '', '', filePath);
      await MediaDownload().openMediaFile(filePath).then((onValue){
        return true;
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  void _deleteFile(String filePath) {
    File file = File(filePath);
    if (file.existsSync()) {
      file.delete();
    }
  }

  void _cancelDownload() {
    setState(() {
      _isDownloading = false;
    });
    dio.close(force: true);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(Singleton.instance.translate('downloading_title'), style: AppTextStyles.main18bold,),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(value: _progress, color: AppColors.red,),
          const SizedBox(height: 10),
          Text("${(_progress * 100).toStringAsFixed(0)}%", style: AppTextStyles.main16regular,),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _cancelDownload,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(Singleton.instance.translate('cancel_title'), style: AppTextStyles.main16regular.copyWith(color: AppColors.white)),
        )
      ],
    );
  }
}