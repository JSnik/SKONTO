import 'package:flutter/material.dart';
import 'package:radio_skonto/helpers/singleton.dart';

const List<String> languageList = [
  'English',
  'Latviski'
];

// deniss.f@efumo.lv
// Option123)

//const apiBaseUrl = 'https://skonto.tst.lv';
//const apiBaseUrl = 'https://skonto2.tst.lv';
//const apiBaseUrl =  'http://skonto2.mediaresearch.lv';


//PROD
const apiBaseUrl = 'https://skontotev.lv';
//41 76 528 63 41

class App {
  static const padding = 24.0;
  static const edgeInsets = EdgeInsets.symmetric(horizontal: padding);
  static const empty = SizedBox.shrink();
  static const expanded = Expanded(child: empty);

  static BoxShadow appBoxShadow = BoxShadow(
    color: Colors.black54.withOpacity(0.3),
    blurRadius: 20,
    offset: const Offset(-2, 15), // changes position of shadow
  );
}

const backgroundLoungeFm = 'assets/image/LOUNGE_FM.png';
const backgroundSconto = 'assets/image/RADIO_SKONTO.png';
const backgroundScontoPlus= 'assets/image/RADIO_SKONTO_PLUS.png';
const backgroundTev = 'assets/image/RADIO_TEV.png';
const backgroundTevLv = 'assets/image/TEV_LV.png';
