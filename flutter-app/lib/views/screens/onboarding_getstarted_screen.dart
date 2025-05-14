import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/repositories/user_repository.dart';
import 'package:read_the_label/services/auth_service.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

class OnboardingGetstartedScreen extends StatefulWidget {
  const OnboardingGetstartedScreen({super.key});

  @override
  State<OnboardingGetstartedScreen> createState() =>
      _OnboardingGetstartedScreenState();
}

class _OnboardingGetstartedScreenState extends State<OnboardingGetstartedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _formFadeAnimation;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _expanded = false;
  bool _showSignInForm = false;
  bool _isLogin = true; // Toggle between Login and Register

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _heightAnimation = Tween<double>(
      begin: 0.30, // Height factor when collapsed
      end: 0.55, // Height factor when expanded
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _textFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        // Use an interval to make the text fade out in the first half of the animation
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _formFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        // Make the form fade in during the second half of the animation
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showSignInForm = true;
        });
      }
      if (status == AnimationStatus.dismissed) {
        setState(() {
          _showSignInForm = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/onboarding_signin_screen.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _heightAnimation,
              builder: (context, child) {
                return Container(
                  height: size.height * _heightAnimation.value,
                  constraints: BoxConstraints(
                    // Ensure the container doesn't exceed 80% of screen height
                    maxHeight: size.height * 0.8,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlack,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    physics: _expanded
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize
                            .min, // Let the column take only needed space
                        children: [
                          // Title section
                          AnimatedBuilder(
                            animation: _textFadeAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _textFadeAnimation.value,
                                child: child,
                              );
                            },
                            child: !_showSignInForm
                                ? Column(
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          style: AppTextStyles.onboardingTitle,
                                          children: [
                                            const TextSpan(
                                                text:
                                                    "Let's make healthy food choices.\n"),
                                            TextSpan(
                                              text: "Together.",
                                              style: AppTextStyles
                                                  .onboardingAccent,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "Helping people understand what they eat, one scan at a time. Make informed choices for better nutrition.",
                                        style: AppTextStyles.withColor(
                                          AppTextStyles.bodyMedium,
                                          Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: _toggleExpansion,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primaryWhite,
                                                foregroundColor:
                                                    AppColors.primaryBlack,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 16,
                                                ),
                                              ),
                                              child: Text(
                                                "Get Started",
                                                style: AppTextStyles
                                                    .buttonTextBlack,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),

                          if (_showSignInForm)
                            AnimatedBuilder(
                              animation: _formFadeAnimation,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _formFadeAnimation.value,
                                  child: child,
                                );
                              },
                              child: Column(
                                children: [
                                  Text("Sign In",
                                      style: AppTextStyles.heading1),
                                  const SizedBox(height: 20),
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        // Email field
                                        TextFormField(
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          style: const TextStyle(
                                            fontFamily:
                                                AppTextStyles.fontFamily,
                                            color: AppColors.primaryWhite,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: 'Email',
                                            labelStyle: TextStyle(
                                              fontFamily:
                                                  AppTextStyles.fontFamily,
                                              color: Colors.white70,
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.email_outlined,
                                              color: Colors.white70,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: const BorderSide(
                                                  color: Colors.white30),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFF9ACD32)),
                                            ),
                                            filled: true,
                                            fillColor: AppColors.primaryWhite
                                                .withOpacity(0.1),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter your email';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        // Password field
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: true,
                                          style: const TextStyle(
                                            fontFamily:
                                                AppTextStyles.fontFamily,
                                            color: AppColors.primaryWhite,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: 'Password',
                                            labelStyle: TextStyle(
                                              fontFamily:
                                                  AppTextStyles.fontFamily,
                                              color: Colors.white70,
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.lock_outline,
                                              color: Colors.white70,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: const BorderSide(
                                                  color: Colors.white30),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: const BorderSide(
                                                  color: Color(0xFF9ACD32)),
                                            ),
                                            filled: true,
                                            fillColor: AppColors.primaryWhite
                                                .withOpacity(0.1),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter your password';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 24),

                                        // Login/Register button
                                        Row(
                                          children: [
                                            // Register button
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _isLogin = false;
                                                  });
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    // Implement register logic
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: !_isLogin
                                                      ? AppColors.primaryWhite
                                                      : AppColors.primaryBlack,
                                                  foregroundColor:
                                                      AppColors.primaryBlack,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    side: const BorderSide(
                                                        color: AppColors
                                                            .primaryWhite),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                ),
                                                child: Text("Register",
                                                    style: AppTextStyles
                                                        .buttonTextWhite),
                                              ),
                                            ),

                                            const SizedBox(width: 16),

                                            //Login button
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    // Implement login logic
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: _isLogin
                                                      ? AppColors.primaryWhite
                                                      : AppColors.primaryWhite
                                                          .withOpacity(0.3),
                                                  foregroundColor:
                                                      AppColors.primaryBlack,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 12),
                                                ),
                                                child: Text(
                                                  "Login",
                                                  style: AppTextStyles
                                                      .buttonTextBlack,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 24),
                                        // OR divider
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 1,
                                                color: Colors.white30,
                                              ),
                                            ),
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16),
                                              child: Text(
                                                'OR',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                height: 1,
                                                color: Colors.white30,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),

                                        // Google sign-in button
                                        ElevatedButton.icon(
                                          icon: Image.asset(
                                            'assets/images/google_icon.png',
                                            height: 20,
                                          ),
                                          onPressed: () async {
                                            final uiViewModel =
                                                Provider.of<UiViewModel>(
                                                    context,
                                                    listen: false);

                                            try {
                                              uiViewModel.setLoading(true);

                                              final authService =
                                                  Provider.of<AuthService>(
                                                      context,
                                                      listen: false);
                                              final result = await authService
                                                  .signInWithGoogle();

                                              if (result != null) {
                                                if (context.mounted) {
                                                  final user =
                                                      authService.currentUser;
                                                  if (user == null) {
                                                    logger.e(
                                                        "Authentication successful but user is null");
                                                    throw Exception(
                                                        "Authentication failed");
                                                  }

                                                  logger.i(
                                                      "Successfully signed in with Google: ${user.email}");

                                                  final userRepository =
                                                      Provider.of<
                                                              UserRepository>(
                                                          context,
                                                          listen: false);
                                                  final isNewUser =
                                                      await userRepository
                                                          .isNewUser();
                                                  logger.i(
                                                      "Is new user: $isNewUser");

                                                  if (isNewUser) {
                                                    await userRepository
                                                        .createUser(
                                                      user.uid,
                                                      user.email ?? "",
                                                      user.displayName ?? "",
                                                    );
                                                    // New user - go through onboarding
                                                    logger.i(
                                                        "Navigating to onboarding flow");
                                                    if (context.mounted) {
                                                      Navigator.pushNamed(
                                                          context,
                                                          '/onboarding-food-preference');
                                                    }
                                                  } else {
                                                    // Check if User onboarding completed
                                                    logger.i(
                                                        "Checking if onboarding is completed");
                                                    final onboardingCompleted =
                                                        await userRepository
                                                            .isOnboardingComplete(
                                                      firebaseUid: user.uid,
                                                    );

                                                    if (!onboardingCompleted) {
                                                      logger.i(
                                                          "User onboarding not completed");
                                                      logger.i(
                                                          "Navigating to onboarding flow");
                                                      if (context.mounted) {
                                                        Navigator.pushNamed(
                                                            context,
                                                            '/onboarding-food-preference');
                                                      }
                                                    } else {
                                                      logger.i(
                                                          "User onboarding completed");
                                                      // Existing user - straight to home
                                                      logger.i(
                                                          "Navigating directly to home");

                                                      if (context.mounted) {
                                                        // Get user data here if needed (preferences, etc.)
                                                        // await userRepository.getUserDetails();

                                                        Navigator
                                                            .pushNamedAndRemoveUntil(
                                                          context,
                                                          '/home',
                                                          (route) => false,
                                                        );
                                                      }
                                                    }
                                                  }
                                                }
                                              } else {
                                                // User cancelled the sign-in flow
                                                logger.w(
                                                    "Sign-in was cancelled by user");
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "Sign-in was cancelled"),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              // Handle errors
                                              logger.e(
                                                  "Error during Google sign-in: $e");
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Sign-in error: ${e.toString().split('\n')[0]}"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            } finally {
                                              // Hide loading indicator
                                              if (context.mounted) {
                                                uiViewModel.setLoading(false);
                                              }
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.primaryWhite,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            padding: const EdgeInsets.all(12),
                                          ),
                                          label: Text("Sign in with Google",
                                              style: AppTextStyles
                                                  .buttonTextBlack),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          "By continuing, you agree to our Terms of Service and Privacy Policy",
                                          style: AppTextStyles.withColor(
                                            AppTextStyles.bodySmall,
                                            Colors.white60,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Loading overlay using UiViewModel
          Consumer<UiViewModel>(
            builder: (context, uiViewModel, child) {
              return uiViewModel.loading
                  ? Container(
                      color: AppColors.primaryBlack.withOpacity(0.7),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondaryGreen,
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
      // resizeToAvoidBottomInset: false,
    );
  }
}
