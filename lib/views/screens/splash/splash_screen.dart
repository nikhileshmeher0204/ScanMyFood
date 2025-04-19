import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/repositories/storage_repository.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';
import 'package:read_the_label/views/screens/home/home_page.dart';
import 'package:read_the_label/views/screens/onboarding/on_boarding_screen.dart';
import 'package:read_the_label/views/screens/user_info/user_info_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await context.read<StorageRepository>().initStorageRepository();
    _checkUserAndNavigate();
  }

  Future<void> _checkUserAndNavigate() async {
    final userInfo = context.read<StorageRepository>().getUserInfo();
    final showOnboarding = context.read<StorageRepository>().isShowOnboarding();
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      if (!showOnboarding) {
        return const OnBoardingScreen();
      } else {
        if (userInfo != null) {
          return const HomePage();
        } else {
          return const UserInfoPage();
        }
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            Assets.images.imBgSplash.path,
            fit: BoxFit.cover,
          ),

          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo and Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PrimarySvgPicture(
                    Assets.icons.icLeaf.path,
                    color: AppColors.green,
                    width: 32,
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'FOOD',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        TextSpan(
                          text: ' SCAN AI',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Progress Bar
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: const LinearProgressIndicator(
                      minHeight: 6,
                      backgroundColor: Color(0xffD9D9D9),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.green),
                    ),
                  )),
              const SizedBox(height: 80),
            ],
          ),
        ],
      ),
    );
  }
}
