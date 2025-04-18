import 'package:flutter/material.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/views/screens/onboarding/ob_content.dart';
import 'package:read_the_label/views/screens/user_info/user_info_page.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        children: [
          OBContent(
            onPressContinue: () {
              _controller.nextPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn,
              );
            },
            image: Assets.images.imOnboarding1.path,
            index: 1,
          ),
          OBContent(
            onPressContinue: () {
              _controller.nextPage(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeIn,
              );
            },
            image: Assets.images.imOnboarding2.path,
            index: 2,
          ),
          OBContent(
            onPressContinue: () {
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) {
                  return const UserInfoPage();
                },
              ));
            },
            image: Assets.images.imOnboarding3.path,
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget buildImageOnboarding(String image) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
