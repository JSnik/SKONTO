import 'package:flutter/material.dart';
import 'package:radio_skonto/helpers/app_colors.dart';
import 'package:radio_skonto/helpers/app_text_style.dart';

class TextWithRedDotWidget extends StatelessWidget {
  const TextWithRedDotWidget({required this.text, super.key, this.secondBoldText,});

  final String text;
  final String? secondBoldText;

  @override
  Widget build(BuildContext context) {
    // return Row(children: [
    //   Text(text, style: AppTextStyles.main16regular),
    //   Text(' *', style: AppTextStyles.main27bold.copyWith(color: AppColors.red)),
    // ],
    // );
    return RichText(
      text: TextSpan(
        style: AppTextStyles.main18regular,
        children: <TextSpan>[
          TextSpan(text: text, style: AppTextStyles.main16regular),
          secondBoldText == null ? const TextSpan(text: '') : TextSpan(text: ' $secondBoldText', style: AppTextStyles.main16bold),
          TextSpan(text: ' *', style: AppTextStyles.main24bold.copyWith(color: AppColors.red)),
        ],
      ),
    );
  }
}