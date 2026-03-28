import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/core/constants/app_constants.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/daily_intake_view_model.dart';

class UserSwitchCard extends StatelessWidget {
  const UserSwitchCard({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return AppConstants.greetingMorning;
    } else if (hour >= 12 && hour < 17) {
      return AppConstants.greetingAfternoon;
    } else {
      return AppConstants.greetingEvening;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user =
        context.read<DailyIntakeViewModel>().authService.currentUser;
    // user.photoURL
    return Column(
      children: [
        Row(
          spacing: 10,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(user?.photoURL ??
                  'https://www.gravatar.com/avatar/placeholder'),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.primaryWhite.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  user?.displayName ?? 'Guest User',
                  style: AppTextStyles.heading3Bold,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
