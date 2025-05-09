import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_carplay/flutter_carplay.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:radio_skonto/helpers/app_theme.dart';
import 'package:radio_skonto/helpers/singleton.dart';
import 'package:radio_skonto/providers/auth_provider.dart';
import 'package:radio_skonto/providers/download_provider.dart';
import 'package:radio_skonto/providers/main_screen_provider.dart';
import 'package:radio_skonto/providers/profile_provider.dart';
import 'package:radio_skonto/providers/search_provider.dart';
import 'package:radio_skonto/screens/navigation_bar/navigation_bar.dart';
import 'package:radio_skonto/screens/splash_screen/splash_screen.dart';
import 'core/extensions.dart';
import 'providers/detail_provider.dart';
import 'providers/main/main_block.dart';
import 'providers/player_provider.dart';
import 'providers/playlists_provider.dart';
import 'providers/podcasts_provider.dart';
import 'providers/report_bug.dart';
import 'providers/translations_provider.dart';
import 'screens/login_screen/login_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
final globalKeyNavigationBar = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  await Singleton.instance.initSharedPreferences();
  HttpOverrides.global = MyHttpOverrides();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ReportBugProvider()),
        BlocProvider(create: (_) => MainBloc()..startCheckConnection()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => TranslationsProvider()),
        ChangeNotifierProvider(create: (_) => PodcastsProvider()),
        ChangeNotifierProvider(create: (_) => MainScreenProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => DetailProvider()),
        ChangeNotifierProvider(create: (_) => DownloadProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistsProvider()),
      ],
      child: MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          home:  Scaffold(body: const SplashScreen(), key: globalKeyNavigationBar,),
          routes: {
            MyNavigationBar.routeName: (context) => const MyNavigationBar(),
            '/login': (context) => const LoginScreen(),
          }),
    );
  }
}

class CarPlayService {
  static Future<void> showMessage(String message) async {
    try {
      final action = CPAlertAction(
        title: 'OK',
        onPress: () {
          FlutterCarplay.pop();
        },
      );

      // Create the alert template with title, message, and actions
      final alertTemplate = CPAlertTemplate(
        actions: [action],
        titleVariants: [message],
      );
      FlutterCarplay.showAlert(template: alertTemplate);
    } on PlatformException catch (e) {
      print("Failed to show message: ${e.message}");
    }
  }
}
