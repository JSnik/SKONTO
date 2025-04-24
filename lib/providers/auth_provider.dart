import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_skonto/helpers/api_helper.dart';
import 'package:radio_skonto/helpers/singleton.dart';
import 'package:radio_skonto/providers/profile_provider.dart';
import 'package:radio_skonto/screens/forgot_password/forgot_password_new_password_screen.dart';
import 'package:radio_skonto/screens/login_screen/login_screen.dart';
import 'package:radio_skonto/screens/navigation_bar/navigation_bar.dart';
import 'package:radio_skonto/screens/verification_screens/email_verification_screen.dart';
import 'package:radio_skonto/screens/verification_screens/phone_verification_screen.dart';
import '../models/place_of_residence_model.dart';

class AuthProvider with ChangeNotifier {

  ResponseState loginResponseState = ResponseState.stateFirsLoad;
  ResponseState registerResponseState = ResponseState.stateFirsLoad;
  ResponseState emailVerificationResponseState = ResponseState.stateFirsLoad;
  ResponseState resendEmailVerificationResponseState = ResponseState.stateFirsLoad;
  ResponseState phoneVerificationResponseState = ResponseState.stateFirsLoad;
  ResponseState phoneResendVerificationResponseState = ResponseState.stateFirsLoad;
  ResponseState changePasswordResponseState = ResponseState.stateFirsLoad;
  ResponseState forgotPasswordResponseState = ResponseState.stateFirsLoad;
  ResponseState forgotPasswordNewPasswordResponseState = ResponseState.stateFirsLoad;
  ResponseState refreshTokenResponseState = ResponseState.stateFirsLoad;

  String registerName = '';
  String registerSurname = '';
  String prizeShippingAddress = '';
  String currentResidence = '';
  int currentResidenceId = 0;
  String registerYearOfBirth = '';
  bool registerWomen = false;
  bool registerMan = false;
  bool registerEducationBasic = false;
  bool registerEducationAverage = false;
  bool registerEducationHighest = false;
  String registerEmail = '';
  String registerPhoneCode = '371';
  String registerPhone = '';
  String registerPassword = '';
  String registerRepeatPassword = '';
  bool registerPrivacyPolicy = false;
  bool registerIsButtonRegisterPress = false;

  String registrationEmailToken = '';
  String registrationPhoneToken = '';
  String emailOnForgotPassword = '';

  PlaceOfResidenceModel placesOfResidence = PlaceOfResidenceModel(apiVersion: '', data:{});

  Future<void> login(String userName, String password, BuildContext context) async {
    if (userName == '') {
      userName = Singleton.instance.getLoginFromSharedPreferences();
    }
    if (userName == '' || password == '') return;

    loginResponseState = ResponseState.stateLoading;
    notifyListeners();
    String apiKey = '/api/login';
    ApiHelper helper = ApiHelper();

    Map<String, dynamic> finishBody = {'login': userName, 'password': password, "locale": "lv"};
    var body = json.encode(finishBody);

    final response = await helper.post(apiKey, null, body);

    var test = json.decode(response.body);

    if (json.decode(response.body) != null && json.decode(response.body)['data'] != null) {
      if (json.decode(response.body)['data']['accessToken'] != null) {
        Singleton.instance.writeLoginToSharedPreferences(userName);
        String _token = json.decode(response.body)['data']['accessToken'];
        String _refreshToken = json.decode(response.body)['data']['refreshToken']?? '';
        Singleton.instance.writeRefreshTokenToSharedPreferences(_refreshToken);
        Singleton.instance.writeTokenToSharedPreferences(_token);
        Singleton.instance.showSuccessMassageFromContext(Singleton.instance.translate('authorization_successful'), context);
        String userNameSaved = Singleton.instance.getUserNameFromSharedPreferences();
        if (userNameSaved == '') {
          Provider.of<ProfileProvider>(context, listen: false).getProfileData(context).then((onValue) {
          });
        }
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      if (json.decode(response.body)['data']['registrationToken'] != null && json.decode(response.body)['data']['isEmailVerified'] != null) {
        Singleton.instance.registrationToken = json.decode(response.body)['data']['registrationToken'];
        bool isEmailVerified = json.decode(response.body)['data']['isEmailVerified'];
        bool isPhoneVerified = json.decode(response.body)['data']['isPhoneVerified'];

        if (isEmailVerified == false) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: ((context) => EmailVerificationScreen(email: userName.contains('37') ? '' : userName)),
          ));
        } else if (isPhoneVerified == false) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: ((context) => PhoneVerificationScreen(phone: userName.contains('37') ? userName : '')),
          ));
        }
      }
      loginResponseState = ResponseState.stateSuccess;
      notifyListeners();
    } else {
      Singleton.instance.handleResponseError(context, response.body);
      loginResponseState = ResponseState.stateError;
      notifyListeners();
    }
  }

  Future<void> register(BuildContext context) async {
    String languageCode = Singleton.instance.getLanguageCodeFromSharedPreferences();
    registerResponseState = ResponseState.stateLoading;
    notifyListeners();
    String apiKey = '/api/registration/$languageCode';
    ApiHelper helper = ApiHelper();

    String? personSex = registerWomen ? 'female' : registerMan ? 'male' : null;
    String? education = registerEducationBasic ? 'basic' : registerEducationAverage ? 'intermediate' : registerEducationHighest ? 'advanced' : null;

    Map<String, dynamic> finishBody = {
      'firstName': registerName,
      'lastName': registerSurname,
      'email': registerEmail,
      'phone': '+' + registerPhoneCode + registerPhone,
      //'phone': '+' + '41765286341',
      'birthYear': registerYearOfBirth,
      'prizeShippingAddress': prizeShippingAddress,
      'personSex': personSex,
      'education': education,
      'password': registerPassword
    };

    if (currentResidenceId != 0) {
      finishBody['city'] = currentResidenceId;
    }
    var body = json.encode(finishBody);
    final response = await helper.post(apiKey, null, body);

    //var test = json.decode(response.body);

    if (json.decode(response.body) != null && json.decode(response.body)['data'] != null) {

      Singleton.instance.registrationToken = json.decode(response.body)['data']['registrationToken'];
      bool isEmailVerified = json.decode(response.body)['data']['isEmailVerified'];
      bool isPhoneVerified = json.decode(response.body)['data']['isPhoneVerified'];

      registerResponseState = ResponseState.stateSuccess;
      notifyListeners();
      Navigator.of(context).push(MaterialPageRoute(
        builder: ((context) => EmailVerificationScreen(email: registerEmail,)),
      ));
    } else {
      var errorTest = jsonDecode(response.body);
      if (errorTest['error'] != null && errorTest['error']['info'] != null) {
        Map errorMap = errorTest['error']['info'];
        String error = '';
        for (String e in errorMap.values) {
          error = '$error$e \n';
        }
        Singleton.instance.showErrorMassageFromContext(
            Singleton.instance.translate('error'),
            error,
            context
        );
      } else {
        Singleton.instance.showErrorMassageFromContext(
            Singleton.instance.translate('error'),
            Singleton.instance.translate('invalid_request'),
            context
        );
      }
      registerResponseState = ResponseState.stateError;
      notifyListeners();
    }
  }

  Future<void> forgotPassword(String email, BuildContext context) async {
    emailOnForgotPassword = email;
    String languageCode = Singleton.instance.getLanguageCodeFromSharedPreferences();
    forgotPasswordResponseState = ResponseState.stateLoading;
    //notifyListeners();
    String apiKey = '/api/forgot-password/$languageCode';
    ApiHelper helper = ApiHelper();

    Map<String, dynamic> finishBody = {
      'email': email
    };
    var body = json.encode(finishBody);
    final response = await helper.post(apiKey, null, body);

    //var test = json.decode(response.body);

    if (response.statusCode == 200) {
      if (json.decode(response.body)['error'] != null) {
        Singleton.instance.handleResponseError(context, response.body);
        forgotPasswordResponseState = ResponseState.stateFirsLoad;
        notifyListeners();
      }
      else if (json.decode(response.body) != null
          && json.decode(response.body)['data'] != null
          && json.decode(response.body)['data']['status'] != null) {
        forgotPasswordResponseState = ResponseState.stateSuccess;
        //Singleton.instance.showSuccessMassageFromContext(Singleton.instance.translate('success_title'), context);
        notifyListeners();
        Navigator.of(context).push(MaterialPageRoute(
          builder: ((context) => const ForgotPasswordNewPasswordScreen()),
        ));
      }
    } else {
      Singleton.instance.handleResponseError(context, response.body);
      forgotPasswordResponseState = ResponseState.stateError;
      notifyListeners();
    }
  }

  Future<void> forgotPasswordNewPassword({required String emailCode, required String newPassword, required String repeatNewPassword, required BuildContext context}) async {
    if (newPassword != repeatNewPassword) {
      return;
    }
    String languageCode = Singleton.instance.getLanguageCodeFromSharedPreferences();
    forgotPasswordNewPasswordResponseState = ResponseState.stateLoading;
    notifyListeners();
    String apiKey = '/api/reset-password/$languageCode';
    ApiHelper helper = ApiHelper();

    Map<String, dynamic> finishBody = {
      'passwordToken': emailCode,
      'newPassword': newPassword,
    };
    var body = json.encode(finishBody);
    final response = await helper.post(apiKey, null, body);

    //var test = json.decode(response.body);
    if (response.statusCode == 200) {
      if (json.decode(response.body)['error'] != null) {
        Singleton.instance.handleResponseError(context, response.body);
        forgotPasswordNewPasswordResponseState = ResponseState.stateFirsLoad;
        notifyListeners();
      }
      else if (json.decode(response.body) != null
          && json.decode(response.body)['data'] != null
          && json.decode(response.body)['data']['status'] != null) {
       // Singleton.instance.showSuccessMassageFromContext(Singleton.instance.translate('success_title'), context);
        if (emailOnForgotPassword != '') {
          login(emailOnForgotPassword, newPassword, context);
          //Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
      forgotPasswordNewPasswordResponseState = ResponseState.stateSuccess;
      //Singleton.instance.showSuccessMassageFromContext(Singleton.instance.translate('success_title'), context);
      notifyListeners();
    } else {
      Singleton.instance.handleResponseError(context, response.body);
      forgotPasswordNewPasswordResponseState = ResponseState.stateError;
      notifyListeners();
    }
  }

  Future<void> verificationEmail(String code, BuildContext context) async {
    if (emailVerificationResponseState != ResponseState.stateLoading) {
      String languageCode = Singleton.instance.getLanguageCodeFromSharedPreferences();
      emailVerificationResponseState = ResponseState.stateLoading;
      //notifyListeners();
      String apiKey = '/api/verify-email/$languageCode/${Singleton.instance.registrationToken}';
      ApiHelper helper = ApiHelper();

      Map<String, dynamic> finishBody = {
        'emailToken': code
      };
      var body = json.encode(finishBody);
      final response = await helper.post(apiKey, null, body);

      //var test = json.decode(response.body);

      if (response.statusCode == 200) {
        if (json.decode(response.body) != null
            && json.decode(response.body)['data'] != null
            && json.decode(response.body)['data']['isEmailVerified'] != null) {

          bool isEmailVerified = json.decode(response.body)['data']['isEmailVerified'];
          bool isPhoneVerified = json.decode(response.body)['data']['isPhoneVerified']?? true;
          if (isEmailVerified == true && isPhoneVerified == false) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: ((context) => PhoneVerificationScreen(phone: registerPhone,)),
            ));
          } else {
            if (json.decode(response.body)['data']['accessToken'] != null) {
              String _token = json.decode(response.body)['data']['accessToken'];
              String _refreshToken = json.decode(response.body)['data']['refreshToken']?? '';
              Singleton.instance.writeRefreshTokenToSharedPreferences(_refreshToken);
              Singleton.instance.writeTokenToSharedPreferences(_token);

              phoneVerificationResponseState = ResponseState.stateSuccess;
              //Singleton.instance.showSuccessMassage(Singleton.instance.translate('message_title'), Singleton.instance.translate('success_title'));
              notifyListeners();

              String userNameSaved = Singleton.instance.getUserNameFromSharedPreferences();
              if (userNameSaved == '') {
                Provider.of<ProfileProvider>(context, listen: false).getProfileData(context);
              }

              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: ((context) => const MyNavigationBar()),
                  fullscreenDialog: true
              ));
            }
          }
        }

        emailVerificationResponseState = ResponseState.stateSuccess;
        notifyListeners();
      } else {
        Singleton.instance.showErrorMassageFromContext(Singleton.instance.translate('error'), Singleton.instance.translate('incorrect_code'), context);
        emailVerificationResponseState = ResponseState.stateError;
        notifyListeners();
      }
    }
  }

  Future<void> resendVerificationEmail(BuildContext context) async {
    String langCode = Singleton.instance.getLanguageCodeFromSharedPreferences();
    resendEmailVerificationResponseState = ResponseState.stateLoading;
    notifyListeners();
    String apiKey = '/api/retry-email-verification/$langCode/${Singleton.instance.registrationToken}';
    ApiHelper helper = ApiHelper();

    Map<String, String> baseHeader = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    final response = await helper.get(apiKey, baseHeader);

    var test = json.decode(response.body);

    if (response.statusCode == 200) {
      Singleton.instance.showSuccessMassageFromContext(Singleton.instance.translate('success_title'), context);
      resendEmailVerificationResponseState = ResponseState.stateSuccess;
      notifyListeners();
    } else {
      resendEmailVerificationResponseState = ResponseState.stateError;
      notifyListeners();
    }
  }

  Future<void> verificationPhone(String code, BuildContext context) async {
    if (phoneVerificationResponseState != ResponseState.stateLoading) {
      String languageCode = Singleton.instance.getLanguageCodeFromSharedPreferences();
      String apiKey = '/api/verify-phone/$languageCode/${Singleton.instance.registrationToken}';
      ApiHelper helper = ApiHelper();

      phoneVerificationResponseState = ResponseState.stateLoading;
      notifyListeners();

      Map<String, dynamic> finishBody = {
        "smsCode": code,
      };
      var body = json.encode(finishBody);
      final response = await helper.post(apiKey, null, body);

      //var test = json.decode(response.body);
      if (response.statusCode == 200) {
        if (json.decode(response.body) != null && json.decode(response.body)['data'] != null) {
          if (json.decode(response.body)['data']['accessToken'] != null) {
            String _token = json.decode(response.body)['data']['accessToken'];
            String _refreshToken = json.decode(response.body)['data']['refreshToken']?? '';
            Singleton.instance.writeRefreshTokenToSharedPreferences(_refreshToken);
            Singleton.instance.writeTokenToSharedPreferences(_token);

            phoneVerificationResponseState = ResponseState.stateSuccess;
            Singleton.instance.showSuccessMassageFromContext(Singleton.instance.translate('registration_successful'), context);
            notifyListeners();

            registerName = '';
            registerSurname = '';
            prizeShippingAddress = '';
            currentResidence = '';
            currentResidenceId = 0;
            registerYearOfBirth = '';
            registerWomen = false;
            registerMan = false;
            registerEducationBasic = false;
            registerEducationAverage = false;
            registerEducationHighest = false;
            registerEmail = '';
            registerPhoneCode = '371';
            registerPhone = '';
            registerPassword = '';
            registerRepeatPassword = '';
            registerPrivacyPolicy = false;
            registerIsButtonRegisterPress = false;

            String userNameSaved = Singleton.instance.getUserNameFromSharedPreferences();
            if (userNameSaved == '') {
              Provider.of<ProfileProvider>(context, listen: false).getProfileData(context);
            }
            Navigator.of(context).popUntil((route) => route.isFirst);

            // Navigator.of(context).pushReplacement(MaterialPageRoute(
            //   builder: ((context) => const MyNavigationBar()),
            //   fullscreenDialog: true
            // ));
          }
        } else {
          Singleton.instance.showErrorMassageFromContext(Singleton.instance.translate('error'), Singleton.instance.translate('incorrect_code'), context);
          phoneVerificationResponseState = ResponseState.stateError;
          notifyListeners();
        }
      } else {
        Singleton.instance.showErrorMassageFromContext(Singleton.instance.translate('error'), Singleton.instance.translate('incorrect_code'), context);
        phoneVerificationResponseState = ResponseState.stateError;
        notifyListeners();
      }
    }
  }

  Future<void> resendVerificationPhone() async {
    String langCode = Singleton.instance.getLanguageCodeFromSharedPreferences();
    phoneResendVerificationResponseState = ResponseState.stateLoading;
    notifyListeners();
    String apiKey = '/api/retry-phone-verification/$langCode/${Singleton.instance.registrationToken}';
    ApiHelper helper = ApiHelper();

    Map<String, String> baseHeader = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    final response = await helper.get(apiKey, baseHeader);

    var test = json.decode(response.body);

    if (response.statusCode == 200) {
      //Singleton.instance.showSuccessMassageFromContext(Singleton.instance.translate('message_title'), Singleton.instance.translate('success_title'), context);
      phoneResendVerificationResponseState = ResponseState.stateSuccess;
      notifyListeners();
    } else {
      phoneResendVerificationResponseState = ResponseState.stateError;
      notifyListeners();
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword, String repeatNewPassword, BuildContext context) async {
    if (newPassword != repeatNewPassword) {
      return;
    }
    if (changePasswordResponseState != ResponseState.stateLoading) {
      String langCode = Singleton.instance.getLanguageCodeFromSharedPreferences();
      changePasswordResponseState = ResponseState.stateLoading;
      notifyListeners();
      String apiKey = '/api/profile/change-password/$langCode';
      ApiHelper helper = ApiHelper();

      Map<String, dynamic> finishBody = {
        //'oldPassword':oldPassword,
        'newPassword':newPassword};
      var body = json.encode(finishBody);

      final response = await helper.postRequestWithToken(url: apiKey, body: body);

      // var test = json.decode(response.body);

      if (response.statusCode == 200) {
        if (json.decode(response.body) != null && json.decode(response.body)['data'] != null) {
          if (json.decode(response.body)['data']['accessToken'] != null) {
            String _token = json.decode(response.body)['data']['accessToken'];
            String _refreshToken = json.decode(response.body)['data']['refreshToken']?? '';
            Singleton.instance.writeRefreshTokenToSharedPreferences(_refreshToken);
            Singleton.instance.writeTokenToSharedPreferences(_token);
            Singleton.instance.showSuccessMassageFromContext(Singleton.instance.translate('success_title'), context);
            changePasswordResponseState = ResponseState.stateSuccess;
            notifyListeners();
            Navigator.of(context).pop();
          }
        } else {
          Singleton.instance.showErrorMassageFromContext(
              Singleton.instance.translate('error'), '', context);
          changePasswordResponseState = ResponseState.stateError;
          notifyListeners();
        }

      } else {
        Singleton.instance.showErrorMassageFromContext(
            Singleton.instance.translate('error'), '', context);
        changePasswordResponseState = ResponseState.stateError;
        notifyListeners();
      }
    }
  }

  Future<void> getPlacesOfResidence() async {
    try {
      String langCode = Singleton.instance.getLanguageCodeFromSharedPreferences();
      String apiKey = '/api/cities/$langCode';
      ApiHelper helper = ApiHelper();

      Map<String, String> baseHeader = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      };
      final response = await helper.get(apiKey, baseHeader);
      if (response.statusCode == 200) {
        placesOfResidence = PlaceOfResidenceModel.fromJson(jsonDecode(response.body));
      }
    } on Exception catch (_) {
    }
  }

  void logout(BuildContext context){
    ApiHelper helper = ApiHelper();
    helper.logout();
    // Singleton.instance.writeRefreshTokenToSharedPreferences('');
    // Singleton.instance.writeTokenToSharedPreferences('');
    // Singleton.instance.writeUserNameToSharedPreferences('');
    notifyListeners();
  }

  bool canPressNextOnRegister(BuildContext context) {
    bool canPress = false;
    if ((registerName.isNotEmpty || !isOnlyWhitespace(registerName)) &&
        (registerSurname.isNotEmpty || !isOnlyWhitespace(registerSurname)) &&
        registerYearOfBirth.isNotEmpty &&
        (registerEmail.isNotEmpty || !isOnlyWhitespace(registerEmail)) &&
        (registerPhone.isNotEmpty || !isOnlyWhitespace(registerPhone)) &&
        registerPassword.isNotEmpty &&
        registerRepeatPassword.isNotEmpty &&
        registerPrivacyPolicy == true &&
        registerPassword == registerRepeatPassword) {
      canPress = true;
    } else {
      showErrorMassage(context);
    }
    return canPress;
  }

  bool isOnlyWhitespace(String str) {
    return str.trim().isEmpty;
  }

  void showErrorMassage(BuildContext context) {
    String massage = '';
    registerName.isEmpty || isOnlyWhitespace(registerName) ? massage = '$massage\n${Singleton.instance.translate('name_title')}' : massage;
    registerSurname.isEmpty || isOnlyWhitespace(registerSurname) ? massage = '$massage\n${Singleton.instance.translate('surname_title')}' : massage;
    registerYearOfBirth.isEmpty ? massage = '$massage\n${Singleton.instance.translate('year_of_birth')}' : massage;
    registerEmail.isEmpty || isOnlyWhitespace(registerEmail) ? massage = '$massage\n${Singleton.instance.translate('e_mail_address')}' : massage;
    registerPhone.isEmpty || isOnlyWhitespace(registerPhone) ? massage = '$massage\n${Singleton.instance.translate('phone_title')}' : massage;
    registerPassword.isEmpty ? massage = '$massage\n${Singleton.instance.translate('password_title')}' : massage;
    registerRepeatPassword.isEmpty ? massage = '$massage\n${Singleton.instance.translate('repeat_the_password')}' : massage;

    Singleton.instance.showErrorMassageFromContext(
        Singleton.instance.translate('value_cannot_be_empty'),
        massage,
        context
    );
  }
}
