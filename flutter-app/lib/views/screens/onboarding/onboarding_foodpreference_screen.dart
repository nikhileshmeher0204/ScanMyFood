import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/models/api_exception.dart';
import 'package:read_the_label/repositories/user_repository.dart';
import 'package:read_the_label/services/auth_service.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/onboarding_view_model.dart';
import 'package:read_the_label/views/widgets/onboarding/choice_card.dart';
import 'package:read_the_label/views/widgets/onboarding/app_selection_field.dart';
import 'package:read_the_label/views/widgets/common/app_cupertino_picker.dart';
import 'package:read_the_label/views/widgets/common/app_picker_modal.dart';
import 'package:read_the_label/views/screens/onboarding/onboarding_health_conditions_screen.dart';

class OnboardingFoodPreferenceScreen extends StatefulWidget {
  const OnboardingFoodPreferenceScreen({super.key});

  @override
  State<OnboardingFoodPreferenceScreen> createState() =>
      _OnboardingFoodpreferenceScreenState();
}

class _OnboardingFoodpreferenceScreenState
    extends State<OnboardingFoodPreferenceScreen> {
  final List<String> _countries = [
    "United States",
    "India",
    "United Kingdom",
    "Canada",
    "Australia",
    "Germany",
    "France",
    "Japan",
    "China",
    // Add more countries as needed
  ];

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final onboardingViewModel = Provider.of<OnboardingViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/onboarding_food_preference_screen_image.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.onboardingTitle,
                children: [
                  TextSpan(
                      text: "Personalize \nyour plate. \n",
                      style: AppTextStyles.heading1),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: AppTextStyles.onboardingTitle,
                            children: [
                              const TextSpan(
                                text:
                                    "Choose your region and dietary preference so we can serve insights that matter to",
                              ),
                              TextSpan(
                                  text: " you. \n",
                                  style: AppTextStyles.onboardingAccent),
                            ],
                          ),
                        ),
                        // Country dropdown section
                        AppSelectionField(
                          label: "Country",
                          icon: Icons.public,
                          value: onboardingViewModel.selectedCountry,
                          onTap: () =>
                              _showCountryPicker(context, onboardingViewModel),
                        ),

                        const SizedBox(height: 24),

                        // Diet preference section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dietary Preference",
                              style: AppTextStyles.withColor(
                                  AppTextStyles.bodyMedium, Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ChoiceCard(
                                    title: "Veg",
                                    iconPath: "assets/icons/veg_icon.png",
                                    accentColor: AppColors.secondaryGreen,
                                    isSelected: onboardingViewModel
                                            .getDietaryPreferenceIndex() ==
                                        0,
                                    onTap: () => onboardingViewModel
                                        .setDietaryPreference(
                                            DietaryPreference.vegetarian),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ChoiceCard(
                                    title: "Non-Veg",
                                    iconPath: "assets/icons/non_veg_icon.png",
                                    accentColor: AppColors.secondaryRed,
                                    isSelected: onboardingViewModel
                                            .getDietaryPreferenceIndex() ==
                                        1,
                                    onTap: () => onboardingViewModel
                                        .setDietaryPreference(
                                            DietaryPreference.nonVegetarian),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ChoiceCard(
                                    title: "Vegan",
                                    iconPath: "assets/icons/vegan_icon.png",
                                    accentColor: AppColors.secondaryGreen,
                                    isSelected: onboardingViewModel
                                            .getDietaryPreferenceIndex() ==
                                        2,
                                    onTap: () => onboardingViewModel
                                        .setDietaryPreference(
                                            DietaryPreference.vegan),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 3.0),
                              child: Icon(
                                Icons.info_outline,
                                size: 14,
                                color: AppColors.primaryWhite,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                "Insights and recommendations will be tailored for your region and dietary preference.",
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving
                                    ? null
                                    : () async {
                                        setState(() {
                                          _isSaving = true;
                                        });

                                        try {
                                          final authService =
                                              Provider.of<AuthService>(context,
                                                  listen: false);
                                          final userRepo =
                                              Provider.of<UserRepository>(
                                                  context,
                                                  listen: false);
                                          final user = authService.currentUser;

                                          if (user == null) {
                                            throw Exception(
                                                "User not logged in");
                                          }

                                          await userRepo.saveUserPreferences(
                                            userId: user.uid,
                                            dietaryPreference: onboardingViewModel
                                                .getDietaryPreferenceString(),
                                            country: onboardingViewModel
                                                .selectedCountry,
                                          );

                                          if (context.mounted) {
                                            Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                builder: (_) => const OnboardingHealthConditionsScreen(),
                                              ),
                                            );
                                          }
                                        } on ApiException catch (e) {
                                          logger.e(
                                              'ApiException saving preferences: $e');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  e.isNotFound
                                                      ? 'Your account was not found. Please sign out and sign in again.'
                                                      : 'Failed to save preferences: ${e.message}',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          logger.e(
                                              'Unexpected error saving preferences: $e');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Unexpected error: ${e.toString()}'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _isSaving = false;
                                            });
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryWhite,
                                  foregroundColor: AppColors.primaryBlack,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primaryBlack,
                                        ),
                                      )
                                    : Text(
                                        "Continue",
                                        style: AppTextStyles.buttonTextBlack,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showCountryPicker(
      BuildContext context, OnboardingViewModel onboardingViewModel) {
    showAppPickerModal(
      context,
      picker: AppCupertinoPicker(
        scrollController: FixedExtentScrollController(
          initialItem: _countries.indexOf(onboardingViewModel.selectedCountry),
        ),
        onSelectedItemChanged: (int index) {
          onboardingViewModel.setCountry(_countries[index]);
        },
        children: _countries.map((String country) {
          return Center(
            child: Text(
              country,
              style: const TextStyle(
                color: AppColors.primaryWhite,
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
