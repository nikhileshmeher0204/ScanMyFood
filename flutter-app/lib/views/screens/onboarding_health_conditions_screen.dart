import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/repositories/user_repository.dart';
import 'package:read_the_label/services/auth_service.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/onboarding_view_model.dart';
import 'package:read_the_label/views/widgets/health_condition_card.dart';

class OnboardingHealthConditionsScreen extends StatefulWidget {
  const OnboardingHealthConditionsScreen({super.key});

  @override
  State<OnboardingHealthConditionsScreen> createState() =>
      _OnboardingHealthConditionsScreenState();
}

class _OnboardingHealthConditionsScreenState
    extends State<OnboardingHealthConditionsScreen> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchConditions());
  }

  Future<void> _fetchConditions() async {
    final viewModel = Provider.of<OnboardingViewModel>(context, listen: false);
    final userRepo = Provider.of<UserRepository>(context, listen: false);

    viewModel.setLoadingConditions(true);
    try {
      final conditions = await userRepo.getHealthConditions();
      viewModel.setAvailableConditions(conditions);
    } catch (e) {
      logger.e("Error fetching health conditions: $e");
    } finally {
      viewModel.setLoadingConditions(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<OnboardingViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background image ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/onboarding_health_conditions_screen_image.png'),
                fit: BoxFit.cover,
              ),
              color: Color(0xFF1B3B2B),
            ),
          ),

          // ── Hero title ─────────────────────────────────────────────────────
          Positioned(
            top: 80,
            left: 24,
            right: 24,
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.onboardingTitle,
                children: [
                  TextSpan(
                    text: "Your ",
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.secondaryGreen,
                    ),
                  ),
                  TextSpan(
                    text: "health,\npersonalized.",
                    style: AppTextStyles.heading1,
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom sheet ───────────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: MediaQuery.of(context).size.height * 0.28,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ───────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 4),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.onboardingTitle,
                        children: const [
                          TextSpan(
                              text:
                                  "Do you have any\npre-existing conditions?"),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                    child: Text(
                      "This helps us tailor better recommendations for your unique needs.",
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),

                  // ── Apple-style inset grouped list ───────────────────────
                  Expanded(
                    child: vm.isLoadingConditions
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.secondaryGreen,
                            ),
                          )
                        : vm.availableConditions.isEmpty
                            ? Center(
                                child: Text(
                                  "No conditions available.",
                                  style: AppTextStyles.bodyMedium,
                                ),
                              )
                            : Padding(
                                // Horizontal inset — Apple's inset grouped style
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    color: AppColors.cardBackground,
                                    child: ListView.separated(
                                      padding: EdgeInsets.zero,
                                      itemCount: vm.availableConditions.length,
                                      separatorBuilder: (_, __) => Divider(
                                        height: 1,
                                        thickness: 0.5,
                                        // Inset divider — Apple standard
                                        indent: 58,
                                        endIndent: 0,
                                        color: Colors.white.withOpacity(0.08),
                                      ),
                                      itemBuilder: (context, index) {
                                        final condition =
                                            vm.availableConditions[index];
                                        return HealthConditionCard(
                                          condition: condition,
                                          isSelected: vm.selectedConditionNames
                                              .contains(condition.name),
                                          onTap: () => vm
                                              .toggleCondition(condition.name),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                  ),

                  // ── Info note ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: AppColors.secondaryBlackTextColor,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            "You can update this anytime in settings.",
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Continue button ───────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveAndContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryWhite,
                          foregroundColor: AppColors.primaryBlack,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndContinue() async {
    setState(() => _isSaving = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userRepo = Provider.of<UserRepository>(context, listen: false);
      final vm = Provider.of<OnboardingViewModel>(context, listen: false);
      final user = authService.currentUser;

      if (user == null) throw Exception("User not logged in");

      await userRepo.saveUserHealthConditions(
        firebaseUid: user.uid,
        conditionNames: vm.selectedConditionNames.toList(),
      );

      if (mounted) {
        Navigator.pushNamed(context, '/onboarding-health-metrics');
      }
    } catch (e) {
      logger.e("Error saving health conditions: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save conditions: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
