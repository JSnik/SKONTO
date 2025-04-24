import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:radio_skonto/helpers/api_helper.dart';
import 'package:radio_skonto/helpers/singleton.dart';
import 'package:radio_skonto/models/search_model.dart';

class SearchProvider with ChangeNotifier {
  ResponseState getSearchResponseState = ResponseState.stateFirsLoad;
  var search = Search.empty();

  final filter = {
    'news': false,
    "podcast": false,
    "interview": false,
    "playlist": false,
    "vacancy": false
  };

  Future<void> getSearch(String query) async {
    String languageCode =
        Singleton.instance.getLanguageCodeFromSharedPreferences();
    getSearchResponseState = ResponseState.stateLoading;
    notifyListeners();
    ApiHelper helper = ApiHelper();
    final queryWithoutSpaces = _getWithoutSpaces(query);
    final apiKey = '/api/search/$queryWithoutSpaces/$languageCode';
    final types = <String>[];
    filter.forEach((key, value) {
      if (value) {
        types.add(key);
      }
    });
    final body = json.encode({'types': types});
    final response = await helper.post(apiKey, null, body);

    if (response.statusCode == 200) {
      var errorTest = jsonDecode(response.body);
      if (errorTest['error'] != null) {
        getSearchResponseState = ResponseState.stateError;
        notifyListeners();
      } else {
        search = searchFromJson(response.body);
        if (search.data.total == 0) {
          filter.forEach((key, value) => filter[key] = false);
        }
        getSearchResponseState = ResponseState.stateSuccess;
        notifyListeners();
      }
    } else {
      getSearchResponseState = ResponseState.stateError;
      notifyListeners();
    }
  }

  void check(String key, bool value) {
    filter[key] = value;
    notifyListeners();
  }

  void setLoadingState() {
    getSearchResponseState = ResponseState.stateLoading;
    notifyListeners();
  }

  void setSuccessState() {
    getSearchResponseState = ResponseState.stateSuccess;
    notifyListeners();
  }

  String _getWithoutSpaces(String s){
    String cleanedText = s.replaceAll(RegExp(r'\s+'), ' ');
    String tmp = cleanedText.trim();
    return _formatLatvianToEng(tmp);
  }

  String _formatLatvianToEng(String latName) {
    String finishName = '';
    for (int i = 0; i < latName.length; i++ ) {
      finishName += _garumzimesMap[latName[i]] ?? latName[i];
    }
    return finishName;
  }

  static const _garumzimesMap = {
    'ā': 'a',
    'č': 'c',
    'ē': 'e',
    'ģ': 'g',
    'ī': 'i',
    'ķ': 'k',
    'ļ': 'l',
    'ņ': 'n',
    'š': 's',
    'ū': 'u',
    'ž': 'z',
    'Ā': 'A',
    'Č': 'C',
    'Ē': 'E',
    'Ģ': 'G',
    'Ī': 'I',
    'Ķ': 'K',
    'Ļ': 'L',
    'Ņ': 'N',
    'Š': 'S',
    'Ū': 'U',
    'Ž': 'Z'
  };
}
