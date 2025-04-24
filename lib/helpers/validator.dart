import 'package:radio_skonto/helpers/singleton.dart';

String? validateNotEmptyField(String value, bool firstLoad) {
  if ((value.isEmpty || isOnlyWhitespace(value)) && firstLoad == false) {
    return Singleton.instance.translate('value_cannot_be_empty');
  }
  return null;
}

bool isOnlyWhitespace(String str) {
  return str.trim().isEmpty;
}

String? validatePasswordField(String value, bool firstLoad) {
  RegExp regex =
  RegExp(r'''^(?=.*[a-z])(?=.*[A-Z])(?=.*[\[\]!@#±5\$%&£+=\\/|€;._,:"\'*{<>}^~\-\?\)\(]).{8,}$''');
  if (value.isEmpty && firstLoad == false) {
    return Singleton.instance.translate('value_cannot_be_empty');
  } else {
    if (!regex.hasMatch(value)) {
      return Singleton.instance.translate('password_rules');
    } else {
      return null;
    }
  }
}

String? validateRepeatPasswordField(String password, String repeatPassword, bool firstLoad) {
  if ((repeatPassword.isEmpty && firstLoad == false) || password != repeatPassword) {
    return Singleton.instance.translate('passwords_not_the_same');
  }
  return null;
}
