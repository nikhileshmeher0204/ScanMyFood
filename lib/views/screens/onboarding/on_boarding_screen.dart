import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/repositories/storage_repository.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/views/screens/user_info/user_info_page.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final List<OnboardingModel> listOnboardingModel = [
    OnboardingModel(
        index: 1,
        image: Assets.images.imOnboarding1.path,
        title: "We help you better understand your eating habits",
        description:
            "In-depth nutritional analysis helps you track daily meal quality and build a sustainable eating routine."),
    OnboardingModel(
        index: 2,
        image: Assets.images.imOnboarding2.path,
        title: "Analyze and display the amount of nutrients in your meals",
        description:
            "Get a detailed nutritional breakdown of every meal, including exact amounts of macronutrients and micronutrients."),
    OnboardingModel(
        index: 3,
        image: Assets.images.imOnboarding3.path,
        title: "Stay on top of your portions and nutrition.",
        description:
            "Easily monitor your portion sizes and stay in control of your daily nutrient intake."),
  ];
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page?.round() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            children: [
              Image.asset(
                listOnboardingModel[0].image,
                fit: BoxFit.fitWidth,
              ),
              Image.asset(
                listOnboardingModel[1].image,
                fit: BoxFit.fitWidth,
              ),
              Image.asset(
                listOnboardingModel[2].image,
                fit: BoxFit.fitWidth,
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: MediaQuery.sizeOf(context).height * 2.5 / 5,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  PageIndicator(
                    currentIndex: _currentPage,
                    itemCount: listOnboardingModel.length,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    listOnboardingModel[_currentPage].title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: Text(
                      listOnboardingModel[_currentPage].description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == 2) {
                          context.read<StorageRepository>().setShowOnboarding();
                          Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context) {
                              return const UserInfoPage();
                            },
                          ));
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _currentPage == 2 ? "Get Started" : 'Continue',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
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

class OnboardingModel {
  final int index;
  final String image;
  final String title;
  final String description;

  OnboardingModel({
    required this.index,
    required this.image,
    required this.title,
    required this.description,
  });
}

class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int itemCount;

  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentIndex == index ? 30 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentIndex == index ? Colors.green : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
