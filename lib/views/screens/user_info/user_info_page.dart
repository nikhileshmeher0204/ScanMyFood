import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/models/user_info.dart';
import 'package:read_the_label/repositories/storage_repository.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/views/common/logo_appbar.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';
import 'package:read_the_label/views/screens/home/home_page.dart';
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
  final _energyController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbonHydrateController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();

  final _formValidNotifier = ValueNotifier<bool>(false);

  void _updateFormValidation() {
    _formValidNotifier.value = _nameController.text.isNotEmpty &&
        _selectedGender.isNotEmpty &&
        _ageController.text.isNotEmpty &&
        _energyController.text.isNotEmpty &&
        _proteinController.text.isNotEmpty &&
        _carbonHydrateController.text.isNotEmpty &&
        _fatController.text.isNotEmpty &&
        _fiberController.text.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateFormValidation);
    _ageController.addListener(_updateFormValidation);
    _energyController.addListener(_updateFormValidation);
    _proteinController.addListener(_updateFormValidation);
    _carbonHydrateController.addListener(_updateFormValidation);
    _fatController.addListener(_updateFormValidation);
    _fiberController.addListener(_updateFormValidation);
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
            const SizedBox(height: 32),
            _buildNutrientInputs(),
            const SizedBox(height: 8),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      TextAlign? textAlign,
      TextInputType? keyboardType,
      String? hintText,
      Color? backgroundIconColor,
      String? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: backgroundIconColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: PrimarySvgPicture(
                  icon,
                  width: 12,
                  color: Colors.white,
                ),
              ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.grey,
                fontFamily: 'Poppins',
              ),
            ),
          ],
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
                color: Color(0xffe3e3e3),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xffe3e3e3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(
                color: Color(0xffe3e3e3),
                width: 1,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
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
              top: const BorderSide(color: Color(0xFFe3e3e3), width: 1),
              bottom: const BorderSide(color: Color(0xFFe3e3e3), width: 1),
              left: BorderSide(
                color: const Color(0xFFe3e3e3),
                width: gender == "Male" ? 1 : 0.1,
              ),
              right: BorderSide(
                color: const Color(0xFFe3e3e3),
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

  Widget _buildNutrientInputs() {
    final nutrients = {
      'Energy': [
        'Calories',
        'kcal',
        Assets.icons.icCalories.path,
        _energyController,
        const Color(0xff6BDE36)
      ],
      'Protein': [
        'Protein',
        'g',
        Assets.icons.icProtein.path,
        _proteinController,
        const Color(0xffFFAF40)
      ],
      'Carbohydrate': [
        'Carbohydrates',
        'g',
        Assets.icons.icCarbonHydrates.path,
        _carbonHydrateController,
        const Color(0xff6B25F6)
      ],
      'Fat': [
        'Fat',
        'g',
        Assets.icons.icFat.path,
        _fatController,
        const Color(0xffFF3F42)
      ],
      'Fiber': [
        'Fiber',
        'g',
        Assets.icons.icFiber.path,
        _fiberController,
        const Color(0xff1CAE54)
      ],
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 0,
        childAspectRatio: 1.7,
      ),
      itemCount: nutrients.length,
      itemBuilder: (context, index) {
        final entry = nutrients.entries.elementAt(index);
        return _buildTextField(
          label: entry.value[0].toString(),
          controller: entry.value[3] as TextEditingController,
          hintText: "0 ${entry.value[1]}",
          icon: entry.value[2].toString(),
          backgroundIconColor: entry.value[4] as Color,
          textAlign: TextAlign.start,
          keyboardType: TextInputType.number,
        );
      },
    );
  }

  Widget _buildContinueButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _formValidNotifier,
      builder: (context, isValid, child) {
        return GestureDetector(
          onTap: isValid ? _saveUserInfo : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: isValid ? AppColors.green : AppColors.grey,
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
      },
    );
  }

  void _saveUserInfo() async {
    final userInfo = UserInfo(
      name: _nameController.text,
      gender: _selectedGender,
      age: int.parse(_ageController.text),
      energy: double.parse(_energyController.text),
      protein: double.parse(_proteinController.text),
      carbohydrate: double.parse(_carbonHydrateController.text),
      fat: double.parse(_fatController.text),
      fiber: double.parse(_fiberController.text),
    );

    context.read<StorageRepository>().saveUserInfo(userInfo);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  void dispose() {
    _formValidNotifier.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _energyController.dispose();
    _carbonHydrateController.dispose();
    _fatController.dispose();
    _ageController.dispose();
    _ageController.dispose();
    _ageController.dispose();

    super.dispose();
  }
}
