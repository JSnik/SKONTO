import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_skonto/core/extensions.dart';
import 'package:radio_skonto/helpers/api_helper.dart';
import 'package:radio_skonto/helpers/app_colors.dart';
import 'package:radio_skonto/helpers/app_text_style.dart';
import 'package:radio_skonto/helpers/singleton.dart';
import 'package:radio_skonto/models/place_of_residence_model.dart';
import 'package:radio_skonto/models/profile_model.dart';
import 'package:radio_skonto/providers/auth_provider.dart';
import 'package:radio_skonto/providers/profile_provider.dart';
import 'package:radio_skonto/screens/profile_screen/change_password_screen.dart';
import 'package:radio_skonto/screens/profile_screen/edit_profile_screen.dart';
import 'package:radio_skonto/widgets/progress_indicator_widget.dart';
import 'package:radio_skonto/widgets/rounded_button_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DatumResidence currentResidence = DatumResidence(id: 0, name: '', postalCode: 0);

  static const _bigPadding = SizedBox(height: 38);
  static const _smallPadding = SizedBox(height: 5);

  @override
  void initState() {
    ProfileProvider profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    profileProvider.getProfileData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ChangeNotifierProvider.value(
          value: Provider.of<ProfileProvider>(context),
          child: Consumer<ProfileProvider>(builder: (context, profileProvider, _) {
            ProfileModel user = profileProvider.userProfile;
            if (Provider.of<AuthProvider>(context, listen: false).placesOfResidence.apiVersion != '' && user.data.city != 0) {
              currentResidence = Provider.of<AuthProvider>(context, listen: false).placesOfResidence.data.values.firstWhere((element) => element.id == user.data.city);
            }
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_outlined, color: AppColors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: profileProvider.getProfileDataResponseState == ResponseState.stateLoading ?
              Center(
                child: AppProgressIndicatorWidget(
                  responseState: profileProvider.getProfileDataResponseState,
                  onRefresh: () {
                    ProfileProvider profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                    profileProvider.getProfileData(context);
                  },
                ),
              ) :
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      10.hs,
                      Text(Singleton.instance.translate('my_profile_title'), style: AppTextStyles.main18bold),
                      _bigPadding,
                      RoutedButtonWidget(title: Singleton.instance.translate('edit_profile_data'), onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                          fullscreenDialog: true,
                        ));
                      }),
                      40.hs,
                      Container(width: double.infinity, height: 2, color: AppColors.gray),

                      _bigPadding,
                      Text(Singleton.instance.translate('personal_information'), style: AppTextStyles.main16bold),
                      _bigPadding,
                      Text(Singleton.instance.translate('name_title'), style: AppTextStyles.main16regular),
                      _smallPadding,
                      Text(user.data.firstName, style: AppTextStyles.main18bold),
                      _bigPadding,
                      Text(Singleton.instance.translate('surname_title'), style: AppTextStyles.main16regular),
                      _smallPadding,
                      Text(user.data.lastName, style: AppTextStyles.main18bold),
                      _bigPadding,
                      Text(Singleton.instance.translate('gender_title'), style: AppTextStyles.main16regular),
                      _smallPadding,
                      Text(getTranslateValue(user.data.personSex), style: AppTextStyles.main18bold),
                      _bigPadding,
                      Text(Singleton.instance.translate('year_of_birth'), style: AppTextStyles.main16regular),
                      _smallPadding,
                      Text(user.data.birthYear.toString(), style: AppTextStyles.main18bold),
                      _bigPadding,
                      Text(Singleton.instance.translate('residence_title'), style: AppTextStyles.main16regular),
                      _smallPadding,
                      Text(currentResidence.name, style: AppTextStyles.main18bold),
                      _bigPadding,
                      Text(Singleton.instance.translate('education_title'), style: AppTextStyles.main16regular),
                      _smallPadding,
                      Text(getTranslateValue(user.data.education), style: AppTextStyles.main18bold),

                      _bigPadding,
                      Container(width: double.infinity, height: 2, color: AppColors.gray),
                      _bigPadding,
                      Text(Singleton.instance.translate('contact_information'), style: AppTextStyles.main16bold),
                      _bigPadding,
                      Text(Singleton.instance.translate('email_title'), style: AppTextStyles.main16regular),
                      _smallPadding,
                      Text(user.data.email, style: AppTextStyles.main18bold),
                      _bigPadding,
                      Text(Singleton.instance.translate('phone_number_title'), style: AppTextStyles.main16regular),
                      _smallPadding,
                      Text(user.data.phone, style: AppTextStyles.main18bold),
                      _bigPadding,
                      Container(width: double.infinity, height: 2, color: AppColors.gray),
                      _bigPadding,

                      Text(Singleton.instance.translate('additional_information_title'), style: AppTextStyles.main16bold),
                      _bigPadding,
                      Text(Singleton.instance.translate('prize_shipping_address'), style: AppTextStyles.main16regular),
                      _smallPadding,
                      Text(user.data.prizeShippingAddress == '' ? '—' : user.data.prizeShippingAddress, style: AppTextStyles.main18bold),
                      _bigPadding,
                      Text(Singleton.instance.translate('card_number'), style: AppTextStyles.main16regular),
                      _smallPadding,
                      Text(user.data.bankCard == '' ? '—' : user.data.bankCard, style: AppTextStyles.main18bold),
                      _bigPadding,
                      Container(width: double.infinity, height: 2, color: AppColors.gray),
                      _bigPadding,
                      Text(Singleton.instance.translate('password_change_title'), style: AppTextStyles.main18bold),
                      _bigPadding,
                      RoutedButtonWidget(title: Singleton.instance.translate('change_password_title'), onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ));
                      }),
                      _bigPadding,
                      Container(width: double.infinity, height: 2, color: AppColors.gray),
                      _bigPadding,
                      Text(Singleton.instance.translate('permanent_deletion_profile'), style: AppTextStyles.main18bold),
                      _bigPadding,
                      RoutedButtonWidget(title: Singleton.instance.translate('delete_profile'), onTap: () {
                        showDeleteProfileDialog(context);
                      }),
                      100.hs,
                    ],
                  ),
                ),
              ),
            );
          })
      ),
    );
  }

  void showDeleteProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0.0))),
          title: Text(Singleton.instance.translate('permanently_delete_profile'), style: AppTextStyles.main24bold, textAlign: TextAlign.center),
          content: Container(
            width: 300,
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(Singleton.instance.translate('profile_will_permanently_deleted'), style: AppTextStyles.main18regular, textAlign: TextAlign.center,),
                15.hs,
                RoutedButtonWidget(
                    borderColor: AppColors.red,
                    textColor: AppColors.white,
                    buttonColor: AppColors.red,
                    isLoading: Provider.of<ProfileProvider>(context, listen: false).deleteProfileDataResponseState == ResponseState.stateLoading ? true : false,
                    title: Singleton.instance.translate('delete_title'), onTap: () {
                  Provider.of<ProfileProvider>(context, listen: false).deleteProfile(context).then((value){
                    if (value == true) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }
                  });
                })
              ],
            ),
          ),
        );
      },
    );
  }

  String getTranslateValue (String key) {
    String value = '';
    value = translateKeys[key]?? '';
    return value;
  }

  Map <String, String> translateKeys = {
    'female' : Singleton.instance.translate('woman_title'),
    'male' : Singleton.instance.translate('man_title'),
    'advanced' : Singleton.instance.translate('highest_education_title'),
    'intermediate' : Singleton.instance.translate('average_education_title'),
    'basic' : Singleton.instance.translate('basic_education_title'),
  };
}



