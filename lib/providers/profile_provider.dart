import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_skonto/helpers/api_helper.dart';
import 'package:radio_skonto/helpers/singleton.dart';
import 'package:radio_skonto/models/profile_model.dart';
import 'package:radio_skonto/providers/auth_provider.dart';
import 'package:radio_skonto/screens/verification_screens/email_verification_screen.dart';
import 'package:radio_skonto/screens/verification_screens/phone_verification_screen.dart';

class ProfileProvider with ChangeNotifier {
  ResponseState getProfileDataResponseState = ResponseState.stateFirsLoad;
  ResponseState saveProfileDataResponseState = ResponseState.stateFirsLoad;
  ResponseState deleteProfileDataResponseState = ResponseState.stateFirsLoad;

  ProfileModel userProfile = ProfileModel(data: Data(firstName: '', lastName: '', email: '', phone: '', birthYear: 2000, personSex: '', education: '', locale: '', city: 0, isMan: false, phoneCode: '', educationBasic: false, educationIntermediate: false, educationAdvanced: false, isWoman: false, prizeShippingAddress: '', bankCard: ''));
  ProfileModel editUserProfile = ProfileModel(data: Data(firstName: '', lastName: '', email: '', phone: '', birthYear: 2000, personSex: '', education: '', locale: '', city: 0, isMan: false, phoneCode: '', educationBasic: false, educationIntermediate: false, educationAdvanced: false, isWoman: false, prizeShippingAddress: '', bankCard: ''));

  Future<void> getProfileData(BuildContext context) async {
    getProfileDataResponseState = ResponseState.stateLoading;
    ApiHelper helper = ApiHelper();
    String languageCode = Singleton.instance.getLanguageCodeFromSharedPreferences();
    String apiKey = '/api/profile/$languageCode';
    final response = await helper.getRequestWithToken(url: apiKey);

    if (response != null && response.statusCode == 200) {
      var errorTest = json.decode(response.body);
      if (errorTest['error'] != null) {
        getProfileDataResponseState = ResponseState.stateError;
        notifyListeners();
      } else {
        userProfile = ProfileModel.fromJson(jsonDecode(response.body));
        editUserProfile = ProfileModel.fromJson(jsonDecode(response.body));
        editUserProfile.data.phone = editUserProfile.data.phone.replaceAll('+371', '');
        Singleton.instance.writeUserNameToSharedPreferences('${userProfile.data.firstName} ${userProfile.data.lastName}');
        getProfileDataResponseState = ResponseState.stateSuccess;
        notifyListeners();
      }
    } else {
      getProfileDataResponseState = ResponseState.stateError;
      notifyListeners();
    }
  }

  Future<void> saveProfileData(BuildContext context) async {
    if (saveProfileDataResponseState != ResponseState.stateLoading) {
      saveProfileDataResponseState = ResponseState.stateLoading;
      notifyListeners();
      ApiHelper helper = ApiHelper();
      String languageCode = Singleton.instance.getLanguageCodeFromSharedPreferences();
      String token = Singleton.instance.getTokenFromSharedPreferences();
      String refToken = Singleton.instance.getRefreshTokenFromSharedPreferences();
      String apiKey = '/api/profile/save/$languageCode/$token';

      Map<String, dynamic> finishBody = {
        'firstName':editUserProfile.data.firstName,
        'lastName':editUserProfile.data.lastName,
        'email':editUserProfile.data.email,
        'phone':'+371${editUserProfile.data.phone}',
        'prizeShippingAddress':editUserProfile.data.prizeShippingAddress,
        'bankCard':editUserProfile.data.bankCard,
        'birthYear': editUserProfile.data.birthYear,
        'personSex': editUserProfile.data.personSex,
        'education':editUserProfile.data.education,
        'locale': editUserProfile.data.locale,
        'city': editUserProfile.data.city};
      var body = json.encode(finishBody);

      final response = await helper.postRequestWithToken(url: apiKey, body: body);
      var test = json.decode(response.body);

      if (response != null && response.statusCode == 200) {
        var errorTest = jsonDecode(response.body);
        if (errorTest['error'] != null) {
          Singleton.instance.handleResponseError(context, response.body);
          saveProfileDataResponseState = ResponseState.stateError;
          notifyListeners();
        } else {
          if (json.decode(response.body)['data']['registrationToken'] != null && json.decode(response.body)['data']['isEmailVerified'] != null) {
            Singleton.instance.registrationToken = json.decode(response.body)['data']['registrationToken'];
            bool isEmailVerified = json.decode(response.body)['data']['isEmailVerified'];
            bool isPhoneVerified = json.decode(response.body)['data']['isPhoneVerified'];
            saveProfileDataResponseState = ResponseState.stateSuccess;
            if (isEmailVerified == false) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: ((context) => EmailVerificationScreen(email: editUserProfile.data.email)),
              ));
            } else if (isPhoneVerified == false) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: ((context) => PhoneVerificationScreen(phone: editUserProfile.data.phone,)),
              ));
            }
          } else {
            Navigator.of(context).pop();
            userProfile.data.firstName = editUserProfile.data.firstName;
            userProfile.data.lastName = editUserProfile.data.lastName;
            userProfile.data.birthYear = editUserProfile.data.birthYear;
            userProfile.data.personSex = editUserProfile.data.personSex;
            userProfile.data.city = editUserProfile.data.city;
            userProfile.data.education = editUserProfile.data.education;
            userProfile.data.email = editUserProfile.data.email;
            userProfile.data.phone = editUserProfile.data.phone;
            userProfile.data.locale = editUserProfile.data.locale;
            userProfile.data.bankCard = editUserProfile.data.bankCard;
            userProfile.data.prizeShippingAddress = editUserProfile.data.prizeShippingAddress;
            Singleton.instance.writeUserNameToSharedPreferences('${userProfile.data.firstName} ${userProfile.data.lastName}');
            Singleton.instance.showSuccessMassageFromContext(Singleton.instance.translate('success_title'), context);
            saveProfileDataResponseState = ResponseState.stateSuccess;
            notifyListeners();
          }
        }
      } else {
        saveProfileDataResponseState = ResponseState.stateError;
        notifyListeners();
      }
    }
  }

  Future<bool> deleteProfile(BuildContext context) async {
    deleteProfileDataResponseState = ResponseState.stateLoading;
    ApiHelper helper = ApiHelper();
    String languageCode = Singleton.instance.getLanguageCodeFromSharedPreferences();
    String apiKey = '/api/profile/delete/$languageCode';
    final response = await helper.getRequestWithToken(url: apiKey);

    //var test = json.decode(response.body);

    if (response != null && response.statusCode == 200 || response.statusCode == 401) {
      helper.logout();
      Singleton.instance.showSuccessMassageFromContext(Singleton.instance.translate('profile_deleted'), context);
      deleteProfileDataResponseState = ResponseState.stateSuccess;
      notifyListeners();

      return true;
      // var errorTest = jsonDecode(response.body);
      // if (errorTest['error'] != null) {
      //   deleteProfileDataResponseState = ResponseState.stateError;
      //   notifyListeners();
      //   return false;
      // } else {
      //   helper.logout();
      //   Singleton.instance.showSuccessMassage(Singleton.instance.translate('message_title'), Singleton.instance.translate('profile_deleted'));
      //   deleteProfileDataResponseState = ResponseState.stateSuccess;
      //   notifyListeners();
      //   return true;
      // }
    } else {
      deleteProfileDataResponseState = ResponseState.stateError;
      notifyListeners();
      return false;
    }
  }

  bool isDataChanged() {
    bool isChanged = true;
    if (userProfile.data.firstName == editUserProfile.data.firstName &&
        userProfile.data.lastName == editUserProfile.data.lastName &&
        userProfile.data.birthYear == editUserProfile.data.birthYear &&
        userProfile.data.personSex == editUserProfile.data.personSex &&
        userProfile.data.city == editUserProfile.data.city &&
        userProfile.data.education == editUserProfile.data.education &&
        userProfile.data.email == editUserProfile.data.email &&
        userProfile.data.phone == editUserProfile.data.phone &&
        userProfile.data.bankCard == editUserProfile.data.bankCard &&
        userProfile.data.prizeShippingAddress == editUserProfile.data.prizeShippingAddress &&
        userProfile.data.locale == editUserProfile.data.locale) {
      isChanged = false;
    }
    return isChanged;
  }

}