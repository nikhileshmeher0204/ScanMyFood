import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      begin: 0.35, // Height factor when collapsed
      end: 0.6, // Height factor when expanded
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
      backgroundColor: Colors.black,
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
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
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
                                        text: const TextSpan(
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 30,
                                            fontWeight: FontWeight.w200,
                                            letterSpacing: -2.5,
                                            height: 1.0,
                                            color: Colors.white,
                                          ),
                                          children: [
                                            TextSpan(
                                                text:
                                                    "Let's make healthy food choices.\n"),
                                            TextSpan(
                                              text: "Together.",
                                              style: TextStyle(
                                                  color: Color(0xFF9ACD32),
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Helping people understand what they eat, one scan at a time. Make informed choices for better nutrition.",
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white70,
                                          height: 1.5,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: _toggleExpansion,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: Colors.black,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
                                              ),
                                              child: const Text(
                                                "Get Started",
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                  letterSpacing: -0.3,
                                                ),
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
                                  const Text(
                                    "Sign In",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -1.0,
                                    ),
                                  ),
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
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: 'Email',
                                            labelStyle: const TextStyle(
                                              fontFamily: 'Inter',
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
                                            fillColor:
                                                Colors.white.withOpacity(0.1),
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
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                          ),
                                          decoration: InputDecoration(
                                            labelText: 'Password',
                                            labelStyle: const TextStyle(
                                              fontFamily: 'Inter',
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
                                            fillColor:
                                                Colors.white.withOpacity(0.1),
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
                                                      ? Colors.white
                                                      : Colors.white
                                                          .withOpacity(0.3),
                                                  foregroundColor: Colors.black,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 16),
                                                ),
                                                child: Text(
                                                  "Register",
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: !_isLogin
                                                        ? Colors.black
                                                        : Colors.white,
                                                    letterSpacing: -0.3,
                                                  ),
                                                ),
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
                                                      ? Colors.white
                                                      : Colors.white
                                                          .withOpacity(0.3),
                                                  foregroundColor: Colors.black,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 16),
                                                ),
                                                child: Text(
                                                  "Login",
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: _isLogin
                                                        ? Colors.black
                                                        : Colors.white,
                                                    letterSpacing: -0.3,
                                                  ),
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
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            // Implement Google Sign-In
                                            final uiProvider =
                                                Provider.of<UiViewModel>(
                                                    context,
                                                    listen: false);
                                            uiProvider.setLoading(true);

                                            // Simulate loading
                                            Future.delayed(
                                                const Duration(seconds: 2), () {
                                              uiProvider.setLoading(false);
                                              // Navigate to home page or next screen
                                            });
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                                color: Colors.white, width: 1),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                          ),
                                          label: const Text(
                                            "Sign in with Google",
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
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
                      color: Colors.black.withOpacity(0.7),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF9ACD32),
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
