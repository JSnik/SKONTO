import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:radio_skonto/helpers/app_colors.dart';
import 'package:radio_skonto/helpers/app_text_style.dart';
import 'package:radio_skonto/helpers/singleton.dart';

class YearSelectorWidget extends StatelessWidget {
  YearSelectorWidget({required this.onSelectYear, required this.initText, super.key, required this.errorText,});

  final Function(String text) onSelectYear;
  final String initText;
  final String? errorText;
  final txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    txtController.text = initText;
    return TextField(
      readOnly: true,
      showCursor: false,
      controller: txtController,
      enableSuggestions: false,
      autocorrect: false,
      onTap: () {
        showYearDialog(context);
      },
      style: AppTextStyles.main18regular,
      decoration: InputDecoration(
        errorText: errorText,
        hintStyle: AppTextStyles.main18regular.copyWith(color: AppColors.gray),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.gray),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.gray),
        ),
        suffixIcon: IconButton(
            onPressed: () {
              showYearDialog(context);
            },
            icon: SvgPicture.asset(
              'assets/icons/row_down.svg',
              width: 8,
              height: 9,
              colorFilter: const ColorFilter.mode(AppColors.black, BlendMode.srcIn),
            ),
        ),
        alignLabelWithHint: true,
      ),
    );
  }

  void showYearDialog(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Singleton.instance.translate('year_of_birth')),
          content: Container(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 100),
              lastDate: DateTime(DateTime.now().year, 1),
              selectedDate: selectedDate,
              onChanged: (DateTime dateTime) {
                onSelectYear(dateTime.year.toString());
                txtController.text = dateTime.year.toString();
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }
}