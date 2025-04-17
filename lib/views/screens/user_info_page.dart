import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/models/user_info.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/views/common/logo_appbar.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';
import 'package:read_the_label/views/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:read_the_label/views/widgets/title_section_widget.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _nameController = TextEditingController();
  String _selectedGender = '';
  final _ageController = TextEditingController();
  final Map<String, TextEditingController> _targetControllers = {
    'Energy': TextEditingController(),
    'Protein': TextEditingController(),
    'Carbohydrate': TextEditingController(),
    'Fat': TextEditingController(),
    'Fiber': TextEditingController(),
  };

  bool get _isFormValid {
    return _nameController.text.isNotEmpty &&
        _selectedGender.isNotEmpty &&
        _ageController.text.isNotEmpty &&
        _targetControllers.values
            .every((controller) => controller.text.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LogoAppbar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TitleSectionWidget(
              title: 'User Information',
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
            _buildTextField(
                label: 'Your Name',
                controller: _nameController,
                hintText: "Enter your name"),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gender',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildGenderButton('Male'),
                          _buildGenderButton('Female'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildTextField(
                      label: 'Age',
                      controller: _ageController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const TitleSectionWidget(
              title: 'Daily Target',
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
            ..._buildNutrientInputs(),
            const SizedBox(height: 32),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextAlign? textAlign,
    TextInputType? keyboardType,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textAlign: textAlign ?? TextAlign.start,
          decoration: InputDecoration(
            filled: true,
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF9F9F9F),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF9F9F9F),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xFF9F9F9F),
                width: 1,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildGenderButton(String gender) {
    final isSelected = _selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = gender),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.green : Colors.transparent,
            borderRadius: gender == "Male"
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30))
                : const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
            border: Border(
              top: const BorderSide(color: Color(0xFF9F9F9F), width: 1),
              bottom: const BorderSide(color: Color(0xFF9F9F9F), width: 1),
              left: BorderSide(
                color: const Color(0xFF9F9F9F),
                width: gender == "Male" ? 1 : 0.1,
              ),
              right: BorderSide(
                color: const Color(0xFF9F9F9F),
                width: gender == "Male" ? 0.1 : 1,
              ),
            ),
          ),
          child: Text(
            gender,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNutrientInputs() {
    final nutrients = {
      'Energy': ['Calories', 'kcal', Assets.icons.icCalories.path],
      'Protein': ['Protein', 'g', Assets.icons.icProtein.path],
      'Carbohydrate': [
        'Carbohydrates',
        'g',
        Assets.icons.icCarbonHydrates.path
      ],
      'Fat': ['Fat', 'g', Assets.icons.icFat.path],
      'Fiber': ['Fiber', 'g', Assets.icons.icFiber.path],
    };

    return nutrients.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: PrimarySvgPicture(
                entry.value[2],
                width: 24,
                color: AppColors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _targetControllers[entry.key],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  hintText: entry.value[0],
                  suffixText: entry.value[1],
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildContinueButton() {
    return GestureDetector(
      onTap: _isFormValid ? _saveUserInfo : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: _isFormValid ? AppColors.green : AppColors.grey,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Text(
          'Continue',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  void _saveUserInfo() async {
    final userInfo = UserInfo(
      name: _nameController.text,
      gender: _selectedGender,
      age: int.parse(_ageController.text),
      dailyTarget: _targetControllers.map(
          (key, controller) => MapEntry(key, double.parse(controller.text))),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_info', jsonEncode(userInfo.toJson()));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    for (var controller in _targetControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
