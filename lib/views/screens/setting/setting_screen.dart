import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/utils/utils.dart';
import 'package:read_the_label/views/common/primary_appbar.dart';
import 'package:read_the_label/views/widgets/rating_bottomsheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PrimaryAppBar(title: "Setting"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // _buildSettingItem(
            //   context,
            //   icon: Assets.icLanguage,
            //   title: "language",
            //   trailing: Text(
            //     context.locale.countryCode != null
            //         ? "${context.locale.languageCode}_${context.locale.countryCode}"
            //
            //         : context.locale.languageCode,
            //     style: AppTextTheme.blackS14
            //         .copyWith(color: AppColor.primaryGreen),
            //   ),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => const LanguageScreen(isFromSetting: true),
            //       ),
            //     );
            //   },
            // ),
            _buildSettingItem(
              context,
              icon: Assets.icons.icShare.path,
              title: "Share App",
              onTap: () async {
                final packageName = await Utils.getAppPackageName();
                Share.share(
                    "https://play.google.com/store/apps/details?id=$packageName");
              },
            ),
            const SizedBox(
              height: 16,
            ),
            _buildSettingItem(
              context,
              icon: Assets.icons.icRateApp.path,
              title: "Rate App",
              onTap: () {
                showRatingBottomSheet(context);
              },
            ),
            const SizedBox(
              height: 16,
            ),
            _buildSettingItem(
              context,
              icon: Assets.icons.icPrivacy.path,
              title: "Privacy Policy",
              onTap: () async {
                final Uri url = Uri.parse(
                    "https://sites.google.com/view/artix-ai-photo-editor/privacy-policy");
                try {
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                } catch (_) {}
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildPremiumBanner(BuildContext context) {
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => const IAPScreen(fromScreen: "setting"),
  //         ),
  //       );
  //     },
  //     child: Container(
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(16),
  //         gradient: const LinearGradient(
  //           colors: [Color(0xffFFA17A), Color(0xffB50AC1)],
  //         ),
  //       ),
  //       padding: const EdgeInsets.all(16),
  //       child: Row(
  //         children: [
  //           Image.asset(Assets.imPreminumSetting, width: 64, height: 64),
  //           const SizedBox(width: 16),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   children: [
  //                     Text(
  //                       "upgrade_to_pro",
  //                       style: AppTextTheme.whiteS20
  //                           .copyWith(fontWeight: FontWeight.w600),
  //                     ),
  //                     const SizedBox(width: 8),
  //                     SvgPicture.asset(Assets.icCircelRightWhite),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   "enjoy_all_features_n_benefits_without_any_restrictions"
  //                       ,
  //                   style: AppTextTheme.whiteS14,
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSettingItem(
    BuildContext context, {
    required String icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      leading: SvgPicture.asset(icon, width: 28, height: 28),
      title: Text(
        title,
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
