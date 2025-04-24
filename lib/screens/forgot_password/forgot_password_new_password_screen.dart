import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_skonto/helpers/api_helper.dart';
import 'package:radio_skonto/helpers/app_colors.dart';
import 'package:radio_skonto/helpers/app_text_style.dart';
import 'package:radio_skonto/helpers/singleton.dart';
import 'package:radio_skonto/helpers/validator.dart';
import 'package:radio_skonto/providers/auth_provider.dart';
import 'package:radio_skonto/screens/verification_screens/phone_verification_screen.dart';
import 'package:radio_skonto/widgets/app_text_field_widget.dart';
import 'package:radio_skonto/widgets/rounded_button_widget.dart';
import 'package:radio_skonto/widgets/text_with_red_dot_widget.dart';

class ForgotPasswordNewPasswordScreen extends StatefulWidget {
  const ForgotPasswordNewPasswordScreen({super.key});

  @override
  State<ForgotPasswordNewPasswordScreen> createState() => _ForgotPasswordNewPasswordScreenState();
}

class _ForgotPasswordNewPasswordScreenState extends State<ForgotPasswordNewPasswordScreen> {
  String emailCode = '';

  String currentPassword = '';
  String password = '';
  String repeatPassword = '';

  bool isFirstLoad = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: Provider.of<AuthProvider>(context),
        child: Consumer<AuthProvider>(builder: (context, authProvider, _) {
          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(
                  color: AppColors.white
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(Singleton.instance.translate('you_can_set_your_new_password'), style: AppTextStyles.main24bold, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        TextWithRedDotWidget(text: Singleton.instance.translate('code_received_by_email'))
                      ],
                    ),
                    AppTextFieldWidget(
                        onChanged: (text) {
                          emailCode = text;
                        }, hintText: Singleton.instance.translate('write_hint_text')),
                    const SizedBox(height: 30),
                    TextWithRedDotWidget(text: Singleton.instance.translate('password_title')),
                    AppTextFieldWidget(
                        isPassword: true,
                        errorText: validatePasswordField(password, isFirstLoad),
                        onChanged: (text) {
                          setState(() {
                            password = text;
                          });
                        }, hintText: ''),
                    const SizedBox(height: 30),
                    TextWithRedDotWidget(text: Singleton.instance.translate('repeat_the_password')),
                    AppTextFieldWidget(
                      isPassword: true,
                      onChanged: (text) {
                        setState(() {
                          repeatPassword = text;
                        });
                      },
                      hintText: '',
                      errorText: validateRepeatPasswordField(password, repeatPassword, isFirstLoad),
                    ),
                    const SizedBox(height: 30),
                    RoutedButtonWidget(
                        isLoading: authProvider.forgotPasswordNewPasswordResponseState == ResponseState.stateLoading ? true : false,
                        title: Singleton.instance.translate('save_title'),
                        onTap: () {
                          isFirstLoad = false;
                          if (authProvider.forgotPasswordNewPasswordResponseState != ResponseState.stateLoading) {
                            authProvider.forgotPasswordNewPassword(
                              emailCode: emailCode,
                              newPassword: password,
                              repeatNewPassword: repeatPassword,
                              context: context,
                            );
                          }
                        }),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          );
        }
        )
    );
  }
}
