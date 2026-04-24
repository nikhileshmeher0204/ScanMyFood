import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/repositories/user_repository.dart';
import 'package:read_the_label/views/screens/home_page.dart';
import 'package:read_the_label/views/screens/onboarding_foodpreference_screen.dart';
import 'package:read_the_label/views/screens/onboarding_getstarted_screen.dart';
import 'package:read_the_label/theme/app_colors.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<Widget>? _nextScreenFuture;
  String? _lastUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<User?>(context);

    // Only re-run the check if the user has changed
    if (user?.uid != _lastUid) {
      _lastUid = user?.uid;
      if (user != null) {
        _nextScreenFuture = _determineNextScreen(user);
      } else {
        _nextScreenFuture = null;
      }
    }
  }

  Future<Widget> _determineNextScreen(User user) async {
    logger.i("AuthWrapper: Determining next screen for user ${user.uid}");
    final userRepository = Provider.of<UserRepository>(context, listen: false);

    try {
      // 1. Check if user is known to our backend
      final userCheckResponse = await userRepository.isNewUser();
      logger.i("AuthWrapper: Is new user: ${userCheckResponse.isNewUser}");
      logger.i(
          "AuthWrapper: Onboarding completed: ${userCheckResponse.isOnboardingComplete}");
      if (userCheckResponse.isNewUser) {
        logger.i(
            "AuthWrapper: User is new, creating record and going to onboarding");
        await userRepository.createUser(
          user.uid,
          user.email ?? "",
          user.displayName ?? "",
        );
        return const OnboardingFoodPreferenceScreen();
      }

      // 2. Check if onboarding is complete
      if (!userCheckResponse.isOnboardingComplete) {
        logger.i(
            "AuthWrapper: Onboarding not complete, going to onboarding flow");
        return const OnboardingFoodPreferenceScreen();
      }

      // 3. All clear, go home
      logger.i("AuthWrapper: User verified, going to home");
      return const HomePage();
    } catch (e, st) {
      logger.e('AuthWrapper: Unexpected error checking user status', e, st);
      return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      return const OnboardingGetstartedScreen();
    }

    return FutureBuilder<Widget>(
      future: _nextScreenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.primaryBlack,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.secondaryGreen,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          logger.e("AuthWrapper: Snapshot error: ${snapshot.error}");
          return const HomePage(); // Fallback
        }

        return snapshot.data ?? const HomePage();
      },
    );
  }
}
