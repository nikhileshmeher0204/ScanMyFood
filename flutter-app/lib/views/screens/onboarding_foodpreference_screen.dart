import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/onboarding_view_model.dart';

class OnboardingFoodPreferenceScreen extends StatefulWidget {
  const OnboardingFoodPreferenceScreen({super.key});

  @override
  State<OnboardingFoodPreferenceScreen> createState() =>
      _OnboardingFoodpreferenceScreenState();
}

class _OnboardingFoodpreferenceScreenState
    extends State<OnboardingFoodPreferenceScreen> {
  String _selectedCountry = "United States";
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
  int _selectedDietIndex = -1; // -1 means no selection

  @override
  Widget build(BuildContext context) {
    final onboardingViewModel =
        Provider.of<OnboardingViewModel>(context, listen: false);

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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Country",
                              style: AppTextStyles.withColor(
                                  AppTextStyles.bodyMedium, Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryWhite.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.white30),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    _showCountryPicker(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    width: double.infinity,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _selectedCountry,
                                          style: AppTextStyles.withColor(
                                            AppTextStyles.bodyLarge,
                                            AppColors.primaryWhite,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: AppColors.primaryWhite,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildPreferenceButton("Veg", 0),
                                  const SizedBox(width: 12),
                                  _buildPreferenceButton("Non-Veg", 1),
                                  const SizedBox(width: 12),
                                  _buildPreferenceButton("Vegan", 2),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/onboarding-health-metrics');
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
                                child: Text(
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

  void _showCountryPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: AppColors.primaryBlack,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white24,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: const Text(
                        'Done',
                        style: TextStyle(color: AppColors.secondaryGreen),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  backgroundColor: AppColors.cardBackground,
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: _countries.indexOf(_selectedCountry),
                  ),
                  onSelectedItemChanged: (int index) {
                    final onboardingViewModel =
                        Provider.of<OnboardingViewModel>(context,
                            listen: false);
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreferenceButton(String label, int index) {
    final onboardingViewModel = Provider.of<OnboardingViewModel>(context);
    final isSelected = onboardingViewModel.getDietaryPreferenceIndex() == index;
    IconData getIconForIndex() {
      switch (index) {
        case 0: // Veg
          return Icons.spa_outlined;
        case 1: // Non-Veg
          return Icons.restaurant_outlined;
        case 2: // Vegan
          return Icons.eco_outlined;
        default:
          return Icons.circle_outlined;
      }
    }

    return GestureDetector(
      onTap: () {
        DietaryPreference preference;
        switch (index) {
          case 0:
            preference = DietaryPreference.vegetarian;
            break;
          case 1:
            preference = DietaryPreference.nonVegetarian;
            break;
          case 2:
            preference = DietaryPreference.vegan;
            break;
          default:
            preference = DietaryPreference.none;
        }
        onboardingViewModel.setDietaryPreference(preference);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryGreen : AppColors.primaryBlack,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.secondaryGreen : Colors.white30,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              getIconForIndex(),
              color:
                  isSelected ? AppColors.primaryBlack : AppColors.primaryWhite,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.withColor(
                AppTextStyles.bodyMedium,
                isSelected ? AppColors.primaryBlack : AppColors.primaryWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
