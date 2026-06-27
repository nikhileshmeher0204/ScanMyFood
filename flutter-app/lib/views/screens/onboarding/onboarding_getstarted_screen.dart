import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/models/auth_result.dart';
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
      begin: 0.28, // Height factor when collapsed
      end: 0.60, // Height factor when expanded
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

  Future<void> _loginWithEmail() async {
    final uiViewModel = Provider.of<UiViewModel>(context, listen: false);
    try {
      uiViewModel.setLoading(true);
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (result.success) {
        logger.i("Email sign-in successful!");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Sign in successful!',
                style: TextStyle(fontFamily: 'Inter'),
              ),
              backgroundColor: AppColors.secondaryGreen,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.errorMessage ?? 'Sign in failed',
                style: const TextStyle(fontFamily: 'Inter'),
              ),
              backgroundColor: AppColors.secondaryRed,
            ),
          );
        }
      }
    } catch (e) {
      logger.e("Error during email sign-in: $e");
    } finally {
      if (mounted) {
        uiViewModel.setLoading(false);
      }
    }
  }

  Future<void> _registerWithEmail() async {
    final uiViewModel = Provider.of<UiViewModel>(context, listen: false);
    try {
      uiViewModel.setLoading(true);
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.registerWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (result.success) {
        logger.i("Email registration successful!");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registration successful!',
                style: TextStyle(fontFamily: 'Inter'),
              ),
              backgroundColor: AppColors.secondaryGreen,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.errorMessage ?? 'Registration failed',
                style: const TextStyle(fontFamily: 'Inter'),
              ),
              backgroundColor: AppColors.secondaryRed,
            ),
          );
        }
      }
    } catch (e) {
      logger.e("Error during email registration: $e");
    } finally {
      if (mounted) {
        uiViewModel.setLoading(false);
      }
    }
  }

  Future<void> _showForgotPasswordDialog(BuildContext context) async {
    final emailController = TextEditingController(text: _emailController.text);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: Text(
            'Reset Password',
            style: AppTextStyles.heading3Bold
                .copyWith(color: AppColors.primaryWhite),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter your email address and we will send you a password reset link.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    color: AppColors.primaryWhite,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF9ACD32)),
                    ),
                    filled: true,
                    fillColor: AppColors.primaryWhite.withOpacity(0.1),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final authService =
                      Provider.of<AuthService>(context, listen: false);
                  Navigator.of(context).pop();

                  final result = await authService
                      .sendPasswordResetEmail(emailController.text);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result.success
                              ? 'Password reset email sent!'
                              : (result.errorMessage ??
                                  'Failed to send reset email'),
                          style: const TextStyle(fontFamily: 'Inter'),
                        ),
                        backgroundColor: result.success
                            ? AppColors.secondaryGreen
                            : AppColors.secondaryRed,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryWhite,
                foregroundColor: AppColors.primaryBlack,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
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
                      padding: EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        top: 32.0,
                        bottom: MediaQuery.of(context).padding.bottom,
                      ),
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
                                    spacing: 16,
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
                                      Text(
                                        "Scan. Track. Share. Build healthier eating habits with the people you care about most.",
                                        style: AppTextStyles.withColor(
                                          AppTextStyles.bodyMedium,
                                          Colors.white70,
                                        ),
                                      ),
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
                                            labelStyle: const TextStyle(
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
                                            if (!RegExp(
                                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                .hasMatch(value)) {
                                              return 'Please enter a valid email address';
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
                                            labelStyle: const TextStyle(
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
                                            if (value.length < 6) {
                                              return 'Password must be at least 6 characters';
                                            }
                                            return null;
                                          },
                                        ),

                                        // Forgot password link (only for sign in mode)
                                        if (_isLogin) ...[
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton(
                                              onPressed: () =>
                                                  _showForgotPasswordDialog(
                                                      context),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: const Size(50, 30),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: Text(
                                                "Forgot Password?",
                                                style: AppTextStyles.withColor(
                                                  AppTextStyles.bodySmall,
                                                  const Color(0xFF9ACD32),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 24),

                                        // Login/Register buttons
                                        Row(
                                          children: [
                                            // Register button
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  if (_isLogin) {
                                                    setState(() {
                                                      _isLogin = false;
                                                    });
                                                  } else {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      await _registerWithEmail();
                                                    }
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: !_isLogin
                                                      ? AppColors.primaryWhite
                                                      : AppColors.primaryBlack,
                                                  foregroundColor: !_isLogin
                                                      ? AppColors.primaryBlack
                                                      : AppColors.primaryWhite,
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
                                                child: Text(
                                                  "Register",
                                                  style: _isLogin
                                                      ? AppTextStyles
                                                          .buttonTextWhite
                                                      : AppTextStyles
                                                          .buttonTextBlack,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 16),

                                            // Login button
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  if (!_isLogin) {
                                                    setState(() {
                                                      _isLogin = true;
                                                    });
                                                  } else {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      await _loginWithEmail();
                                                    }
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: _isLogin
                                                      ? AppColors.primaryWhite
                                                      : AppColors.primaryBlack,
                                                  foregroundColor: _isLogin
                                                      ? AppColors.primaryBlack
                                                      : AppColors.primaryWhite,
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
                                                child: Text(
                                                  "Login",
                                                  style: _isLogin
                                                      ? AppTextStyles
                                                          .buttonTextBlack
                                                      : AppTextStyles
                                                          .buttonTextWhite,
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
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(
                                                  Icons.g_mobiledata,
                                                  color: Colors.black);
                                            },
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

                                              if (result.success) {
                                                logger.i(
                                                    "Successfully signed in with Google");
                                              } else {
                                                if (result.errorType !=
                                                    AuthErrorType.cancelled) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(result
                                                                .errorMessage ??
                                                            "Google Sign-In failed"),
                                                        backgroundColor:
                                                            AppColors
                                                                .secondaryRed,
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            } catch (e) {
                                              logger.e(
                                                  "Error during Google sign-in: $e");
                                            } finally {
                                              if (context.mounted) {
                                                uiViewModel.setLoading(false);
                                              }
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.primaryWhite,
                                            minimumSize:
                                                const Size(double.infinity, 50),
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

                                        // Apple sign-in button (iOS only)
                                        if (!kIsWeb && Platform.isIOS) ...[
                                          const SizedBox(height: 12),
                                          ElevatedButton.icon(
                                            icon: const Icon(
                                              Icons.apple,
                                              color: Colors.black,
                                              size: 24,
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
                                                    .signInWithApple();

                                                if (result.success) {
                                                  logger.i(
                                                      "Successfully signed in with Apple");
                                                } else {
                                                  if (result.errorType !=
                                                      AuthErrorType.cancelled) {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(result
                                                                  .errorMessage ??
                                                              "Apple Sign-In failed"),
                                                          backgroundColor:
                                                              AppColors
                                                                  .secondaryRed,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                }
                                              } catch (e) {
                                                logger.e(
                                                    "Error during Apple sign-in: $e");
                                              } finally {
                                                if (context.mounted) {
                                                  uiViewModel.setLoading(false);
                                                }
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primaryWhite,
                                              minimumSize: const Size(
                                                  double.infinity, 50),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              padding: const EdgeInsets.all(12),
                                            ),
                                            label: Text("Sign in with Apple",
                                                style: AppTextStyles
                                                    .buttonTextBlack),
                                          ),
                                        ],
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
