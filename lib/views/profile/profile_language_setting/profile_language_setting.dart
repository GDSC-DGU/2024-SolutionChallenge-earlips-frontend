import 'package:earlips/utilities/style/color_styles.dart';
import 'package:earlips/viewModels/user/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileLanguageScreen extends StatelessWidget {
  const ProfileLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userViewModel = Get.find<UserViewModel>();
    userViewModel.loadLanguageSettings();

    String title = tr('language_settings');
    String systemLanguage = tr('system_language');
    String learningLanguage = tr('learning_language');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        width: double.infinity,
        color: ColorSystem.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLanguageSettingSection(
                title: systemLanguage,
                selectedLanguage: userViewModel.systemLanguage,
                onLanguageSelected: (value) {
                  userViewModel.systemLanguage.value = value!;
                  userViewModel.updateLanguageSettings();
                },
                languageOptions: [
                  const DropdownMenuItem(value: '한국어', child: Text('한국어')),
                  const DropdownMenuItem(
                      value: 'English', child: Text('English')),
                ],
              ),
              const SizedBox(height: 20),
              _buildLanguageSettingSection(
                title: learningLanguage,
                selectedLanguage: userViewModel.learningLanguage,
                onLanguageSelected: (value) {
                  userViewModel.learningLanguage.value = value!;
                  userViewModel.updateLanguageSettings();
                },
                languageOptions: [
                  const DropdownMenuItem(value: '한국어', child: Text('한국어')),
                  const DropdownMenuItem(
                      value: 'English', child: Text('English')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 셋팅 섹션 위젯
// 셋팅 섹션 위젯
  Widget _buildLanguageSettingSection({
    required String title,
    required RxString selectedLanguage,
    required Function(String?) onLanguageSelected,
    required List<DropdownMenuItem<String>> languageOptions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        Obx(() => DropdownButton<String>(
              value: selectedLanguage.value,
              items: languageOptions,
              onChanged: (newValue) {
                onLanguageSelected(newValue);
                // Call your language change logic here
                // For example:
                // userViewModel.systemLanguage.value = newValue!;
                // userViewModel.updateLanguageSettings();
              },
              hint: Text(tr('select_language') ?? 'fallback_language'),
            )),
      ],
    );
  }
}
