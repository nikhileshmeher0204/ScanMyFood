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
    
    // Representative background color for the saturated sunset orange header region
    const bgHeader = AppColors.sunsetOrange;

    final titleColor = AppColors.getTitleColor(bgHeader);
    final subtitleColor = AppColors.getSubtitleColor(bgHeader);

    return Column(
      children: [
        Row(
          spacing: 12,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: subtitleColor.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.cardBackground.withValues(alpha: 0.3),
                backgroundImage: NetworkImage(user?.photoURL ??
                    'https://www.gravatar.com/avatar/placeholder'),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting().toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: subtitleColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.displayName ?? 'Guest User',
                  style: AppTextStyles.heading3Bold.copyWith(
                    color: titleColor,
                    fontSize: 20,
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                Icons.settings_rounded,
                color: subtitleColor,
                size: 26,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ],
    );
  }
}
