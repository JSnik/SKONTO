import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:radio_skonto/helpers/api_helper.dart';
import 'package:radio_skonto/helpers/singleton.dart';
import 'package:radio_skonto/models/interview_model.dart' as interview;
import 'package:radio_skonto/models/podcasts_model.dart';

enum PodcastType { audio, video, interview }

class PodcastsProvider with ChangeNotifier {
  ResponseState getAudioPodcastsResponseState = ResponseState.stateFirsLoad;
  ResponseState getVideoPodcastsResponseState = ResponseState.stateFirsLoad;
  ResponseState getInterviewPodcastsResponseState = ResponseState.stateFirsLoad;

  Podcasts audioPodcasts = Podcasts(
      apiVersion: '',
      filters: Filters(sort: [], categories: [], subCategories: []),
      data: [],
      banners: []);
  Podcasts videoPodcasts = Podcasts(
      apiVersion: '',
      filters: Filters(sort: [], categories: [], subCategories: []),
      data: [],
      banners: []);
  interview.Interview interviewPodcasts = interview.Interview(
      apiVersion: '',
      filters: interview.Filters(sort: [], categories: []),
      data: [],
      banners: []);
  Filters filtersAudio = Filters(sort: [], categories: [], subCategories: []);
  Filters filtersVideo = Filters(sort: [], categories: [], subCategories: []);
  interview.Filters filtersInterview =
      interview.Filters(sort: [], categories: []);

  int currentAppBarIndex = 0;

  Future<void> getAllPodcasts({required bool isFromInit, var playerProvider}) async {
    getAudioPodcasts(isFromInit, playerProvider: playerProvider);
    getVideoPodcasts(isFromInit);
    getInterviewPodcasts(isFromInit, playerProvider: playerProvider);
  }

  Future<void> initAllPodcasts(
      {required bool isFromInit, var playerProvider}) async {
    initAudioPodcasts(isFromInit, playerProvider: playerProvider);
  }

  Future<void> initAudioPodcasts(bool isFromInit, {var playerProvider}) async {
    getAudioPodcastsResponseState = ResponseState.stateLoading;
    if (isFromInit == false) {
      notifyListeners();
    }
    ApiHelper helper = ApiHelper();
    String languageCode =
        Singleton.instance.getLanguageCodeFromSharedPreferences();
    Sort sortElem = Sort(name: 'Test', sortBy: 'dateFrom', sortOrder: 'desc', isSelected: false);
    'dateFrom';
    if (filtersAudio.sort.isNotEmpty) {
      sortElem = filtersAudio.sort.firstWhere((element) => element.isSelected);
    }

    String apiKey =
        '/api/podcasts/audio/$languageCode/${sortElem.sortBy}/${sortElem.sortOrder}';
    List<int> categoryList = getSelectedCategoriesAudio();
    if (categoryList.isEmpty) {
      categoryList.add(-1);
    }
    Map<String, dynamic> finishBody = {
      'category': categoryList.isEmpty ? null : categoryList
    };
    var body = json.encode(finishBody);

    final response = await helper.initPostRequestWithToken(
      url: apiKey,
      body: body,
    );

    var errorTest = jsonDecode(response.body);
    if (response != null && response.statusCode == 200) {
      var errorTest = jsonDecode(response.body);
      if (errorTest['error'] != null) {
        getAudioPodcastsResponseState = ResponseState.stateError;
        notifyListeners();
      } else {
        audioPodcasts = podcastsFromJson(response.body);
        // await Provider.of<PlayerProvider>(context, listen: false).updateAndroidAutoAndCarPlayItems(audioPodcasts.data);
        audioPodcasts.filters.sort.first.isSelected = true;
        if (filtersAudio.sort.isEmpty) {
          filtersAudio = audioPodcasts.filters;
        } else {
          audioPodcasts.filters = filtersAudio;
        }

        if (playerProvider != null) {
          await playerProvider
              .updateAndroidAutoAndCarPlayItems(audioPodcasts.data);
        }
        getAudioPodcastsResponseState = ResponseState.stateSuccess;
        notifyListeners();
      }
    } else {
      getAudioPodcastsResponseState = ResponseState.stateError;
      notifyListeners();
    }
  }

  Future<void> getAudioPodcasts(bool isFromInit,
      {var playerProvider}) async {
    getAudioPodcastsResponseState = ResponseState.stateLoading;
    if (isFromInit == false) {
      notifyListeners();
    }
    ApiHelper helper = ApiHelper();
    String languageCode =
        Singleton.instance.getLanguageCodeFromSharedPreferences();
    Sort sortElem = Sort(name: 'Test', sortBy: 'dateFrom', sortOrder: 'desc', isSelected: false);
    'dateFrom';
    if (filtersAudio.sort.isNotEmpty) {
      sortElem = filtersAudio.sort.firstWhere((element) => element.isSelected);
    }

    String apiKey =
        '/api/podcasts/audio/$languageCode/${sortElem.sortBy}/${sortElem.sortOrder}';
    List<int> categoryList = getSelectedCategoriesAudio();
    if (categoryList.isEmpty) {
      categoryList.add(-1);
    }
    Map<String, dynamic> finishBody = {
      'category': categoryList.isEmpty ? null : categoryList
    };
    var body = json.encode(finishBody);

    final response = await helper.postRequestWithToken(
        url: apiKey, body: body);

    var errorTest = jsonDecode(response.body);
    if (response != null && response.statusCode == 200) {
      var errorTest = jsonDecode(response.body);
      if (errorTest['error'] != null) {
        getAudioPodcastsResponseState = ResponseState.stateError;
        notifyListeners();
      } else {
        audioPodcasts = podcastsFromJson(response.body);
        // await Provider.of<PlayerProvider>(context, listen: false).updateAndroidAutoAndCarPlayItems(audioPodcasts.data);
        audioPodcasts.filters.sort.first.isSelected = true;
        if (filtersAudio.sort.isEmpty) {
          copyFilters(from: audioPodcasts.filters, to: filtersAudio);
        } else {
          copyFilters(from: filtersAudio, to: audioPodcasts.filters);
        }

        if (playerProvider != null) {
          await playerProvider
              .updateAndroidAutoAndCarPlayItems(audioPodcasts.data);
        }
        getAudioPodcastsResponseState = ResponseState.stateSuccess;
        notifyListeners();
      }
    } else {
      getAudioPodcastsResponseState = ResponseState.stateError;
      notifyListeners();
    }
  }

  Future<void> getVideoPodcasts(bool isFromInit,
      {var playerProvider}) async {
    getVideoPodcastsResponseState = ResponseState.stateLoading;
    if (isFromInit == false) {
      notifyListeners();
    }
    ApiHelper helper = ApiHelper();
    String languageCode =
        Singleton.instance.getLanguageCodeFromSharedPreferences();
    Sort sortElem = Sort(name: 'Test', sortBy: 'dateFrom', sortOrder: 'desc', isSelected: false);
    'dateFrom';
    if (filtersAudio.sort.isNotEmpty) {
      sortElem = filtersAudio.sort.firstWhere((element) => element.isSelected);
    }

    String apiKey =
        '/api/podcasts/video/$languageCode/${sortElem.sortBy}/${sortElem.sortOrder}';
    List<int> categoryList = getSelectedCategoriesVideo();
    if (categoryList.isEmpty) {
      categoryList.add(-1);
    }
    Map<String, dynamic> finishBody = {
      'category': categoryList.isEmpty ? '0' : categoryList
    };
    var body = json.encode(finishBody);

    final response = await helper.postRequestWithToken(
        url: apiKey, body: body);

    if (response != null && response.statusCode == 200) {
      var errorTest = jsonDecode(response.body);
      if (errorTest['error'] != null) {
        getVideoPodcastsResponseState = ResponseState.stateError;
        notifyListeners();
      } else {
        videoPodcasts = podcastsFromJson(response.body);
        if (playerProvider != null) {
          await playerProvider
              .updateAndroidAutoAndCarPlayItems(videoPodcasts.data);
        }
        videoPodcasts.filters.sort.first.isSelected = true;
        if (filtersVideo.sort.isEmpty) {
          copyFilters(from: videoPodcasts.filters, to: filtersVideo);
        } else {
          copyFilters(from: filtersVideo, to: videoPodcasts.filters);
        }
        getVideoPodcastsResponseState = ResponseState.stateSuccess;
        notifyListeners();
      }
    } else {
      getVideoPodcastsResponseState = ResponseState.stateError;
      notifyListeners();
    }
  }

  Future<void> getInterviewPodcasts(bool isFromInit,
      {var playerProvider}) async {
    getInterviewPodcastsResponseState = ResponseState.stateLoading;
    if (isFromInit == false) {
      notifyListeners();
    }
    ApiHelper helper = ApiHelper();
    String languageCode =
        Singleton.instance.getLanguageCodeFromSharedPreferences();
    interview.Sort sortElem =
        interview.Sort(name: 'Test', sortBy: 'default', sortOrder: 'desc', isSelected: false);
    if (filtersInterview.sort.isNotEmpty) {
      for (final f in filtersInterview.sort) {
        if (f.isSelected == true) {
          sortElem = f;
        }
      }
      // sortElem =
      //     filtersInterview.sort.firstWhere((element) => element.isSelected);
    }

    String apiKey =
        '/api/interviews/$languageCode/${sortElem.sortBy}/${sortElem.sortOrder}';
    List<int> categoryList = getSelectedCategoriesInterview();
    Map<String, dynamic> finishBody = {
      'category': categoryList.isEmpty ? null : categoryList
    };
    var body = json.encode(finishBody);

    final response = await helper.postRequestWithToken(
        url: apiKey, body: body);

    if (response != null && response.statusCode == 200) {
      var errorTest = jsonDecode(response.body);
      if (errorTest['error'] != null) {
        getInterviewPodcastsResponseState = ResponseState.stateError;
        notifyListeners();
      } else {
        interviewPodcasts = interview.interviewFromJson(response.body);
        if (playerProvider != null) {
          await playerProvider
              .updateAndroidAutoAndCarPlayItems(interviewPodcasts.data);
        }
        // Future.delayed(const Duration(seconds: 6), () async {
        //   if (playerProvider != null) {
        //     print('********88999998**********');
        //     await playerProvider
        //         .updateAndroidAutoAndCarPlayItems(interviewPodcasts.data);
        //   }
        // });
        if (filtersInterview.sort.isEmpty) {
          copyInterviewFilters(from: interviewPodcasts.filters, to: filtersInterview);
        } else {
          copyInterviewFilters(from: filtersInterview, to: interviewPodcasts.filters);
        }
        getInterviewPodcastsResponseState = ResponseState.stateSuccess;
        notifyListeners();
      }
    } else {
      getInterviewPodcastsResponseState = ResponseState.stateError;
      notifyListeners();
    }
  }

  void refreshDataAfterApplyingFilters() {
    bool isFilterHasChanges = isFiltersHasChanges();
    if (isFilterHasChanges == true) {
      if (currentAppBarIndex == 0) {
        getAudioPodcasts(false);
      }
      if (currentAppBarIndex == 1) {
        getVideoPodcasts(false);
      }
      if (currentAppBarIndex == 2) {
        getInterviewPodcasts(false);
      }
    }
  }

  bool isFiltersHasChanges() {
    if (currentAppBarIndex == 0) {
      for (var i = 0; i < audioPodcasts.filters.sort.length; i++) {
        if (audioPodcasts.filters.sort[i].isSelected !=
            filtersAudio.sort[i].isSelected) {
          return true;
        }
      }
      for (var i = 0; i < audioPodcasts.filters.categories.length; i++) {
        if (audioPodcasts.filters.categories[i].isSelected !=
            filtersAudio.categories[i].isSelected) {
          return true;
        }
      }
      for (var i = 0; i < audioPodcasts.filters.subCategories.length; i++) {
        if (audioPodcasts.filters.subCategories[i].isSelected !=
            filtersAudio.subCategories[i].isSelected) {
          return true;
        }
      }
    }

    if (currentAppBarIndex == 1) {
      for (var i = 0; i < videoPodcasts.filters.sort.length; i++) {
        if (videoPodcasts.filters.sort[i].isSelected !=
            filtersVideo.sort[i].isSelected) {
          return true;
        }
      }
      for (var i = 0; i < videoPodcasts.filters.categories.length; i++) {
        if (videoPodcasts.filters.categories[i].isSelected !=
            filtersVideo.categories[i].isSelected) {
          return true;
        }
      }
      for (var i = 0; i < videoPodcasts.filters.subCategories.length; i++) {
        if (videoPodcasts.filters.subCategories[i].isSelected !=
            filtersVideo.subCategories[i].isSelected) {
          return true;
        }
      }
    }

    if (currentAppBarIndex == 2) {
      for (var i = 0; i < interviewPodcasts.filters.sort.length; i++) {
        if (interviewPodcasts.filters.sort[i].isSelected !=
            filtersInterview.sort[i].isSelected) {
          return true;
        }
      }
      for (var i = 0; i < interviewPodcasts.filters.categories.length; i++) {
        if (interviewPodcasts.filters.categories[i].isSelected !=
            filtersInterview.categories[i].isSelected) {
          return true;
        }
      }
    }

    return false;
  }

  void copyFilters({required Filters from, required Filters to}) {
    if (from.sort.length == to.sort.length) {
      for (int i = 0; i < from.sort.length; i++) {
        to.sort[i].isSelected = from.sort[i].isSelected;
      }
    } else {
      for (int i = 0; i < from.sort.length; i++) {
        final s = Sort(name: from.sort[i].name, sortBy: from.sort[i].sortBy, sortOrder: from.sort[i].sortOrder, isSelected: from.sort[i].isSelected);
        to.sort.add(s);
      }
    }
    if (from.categories.length == to.categories.length) {
      for (int i = 0; i < from.categories.length; i++) {
        to.categories[i].isSelected = from.categories[i].isSelected;
      }
    } else {
      for (int i = 0; i < from.categories.length; i++) {
        AudioPodcast p = AudioPodcast(id: from.categories[i].id, name: from.categories[i].name, created: from.categories[i].created, published: from.categories[i].published, parent: from.categories[i].parent);
        p.isSelected = from.categories[i].isSelected;
        to.categories.add(p);
      }
    }
    if (from.subCategories.length == to.subCategories.length) {
      for (int i = 0; i < from.subCategories.length; i++) {
        to.subCategories[i].isSelected = from.subCategories[i].isSelected;
      }
    } else {
      for (int i = 0; i < from.subCategories.length; i++) {
        AudioPodcast p = AudioPodcast(id: from.subCategories[i].id, name: from.subCategories[i].name, created: from.subCategories[i].created, published: from.subCategories[i].published, parent: from.subCategories[i].parent);
        p.isSelected = from.subCategories[i].isSelected;
        to.subCategories.add(from.subCategories[i]);
      }
    }
  }

  void copyInterviewFilters({required interview.Filters from, required interview.Filters to}) {
    if (from.sort.length == to.sort.length) {
      for (int i = 0; i < from.sort.length; i++) {
        to.sort[i].isSelected = from.sort[i].isSelected;
      }
    } else {
      for (int i = 0; i < from.sort.length; i++) {
        final s = interview.Sort(name: from.sort[i].name, sortBy: from.sort[i].sortBy, sortOrder: from.sort[i].sortOrder, isSelected: from.sort[i].isSelected);
        to.sort.add(s);
      }
    }
    if (from.categories.length == to.categories.length) {
      for (int i = 0; i < from.categories.length; i++) {
        to.categories[i].isSelected = from.categories[i].isSelected;
      }
    } else {
      for (int i = 0; i < from.categories.length; i++) {
        interview.Category p = interview.Category(id: from.categories[i].id, title: from.categories[i].title, created: from.categories[i].created, published: from.categories[i].published);
        p.isSelected = from.categories[i].isSelected;
        to.categories.add(p);
      }
    }
  }

  void setCurrentSortFilter(int sortIndex) {
    if (currentAppBarIndex == 0) {
      for (var element in filtersAudio.sort) {
        element.isSelected = false;
      }
      filtersAudio.sort[sortIndex].isSelected = true;
    }
    if (currentAppBarIndex == 1) {
      for (var element in filtersVideo.sort) {
        element.isSelected = false;
      }
      filtersVideo.sort[sortIndex].isSelected = true;
    }
    if (currentAppBarIndex == 2) {
      for (var element in filtersInterview.sort) {
        element.isSelected = false;
      }
      filtersInterview.sort[sortIndex].isSelected = true;
    }
  }

  List<int> getSelectedCategoriesAudio() {
    List<int> selectedCategories = [];
    for (var c in filtersAudio.categories) {
      if (c.isSelected) {
        selectedCategories.add(c.id);
      }
    }
    for (var c in filtersAudio.subCategories) {
      if (c.isSelected) {
        selectedCategories.add(c.id);
      }
    }
    return selectedCategories;
  }

  List<int> getSelectedCategoriesVideo() {
    List<int> selectedCategories = [];
    for (var c in filtersVideo.categories) {
      if (c.isSelected) {
        selectedCategories.add(c.id);
      }
    }
    for (var c in filtersVideo.subCategories) {
      if (c.isSelected) {
        selectedCategories.add(c.id);
      }
    }
    return selectedCategories;
  }

  List<int> getSelectedCategoriesInterview() {
    List<int> selectedCategories = [];
    for (var c in filtersInterview.categories) {
      if (c.isSelected) {
        selectedCategories.add(c.id);
      }
    }
    return selectedCategories;
  }

  void onFavoriteTap(dynamic item) {}
}
