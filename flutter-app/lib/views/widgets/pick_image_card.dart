import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/theme/app_theme.dart';
import 'package:rive/rive.dart' as rive;

class PickImageCard extends StatelessWidget {
  final IconData icon;
  final String titleDescription;
  final String cameraButtonText;
  final String galleryButtonText;
  final File? image;
  final bool isLoading;
  final Function(ImageSource) onImageCapturePressed;

  const PickImageCard({
    super.key,
    required this.icon,
    required this.titleDescription,
    required this.cameraButtonText,
    required this.galleryButtonText,
    required this.onImageCapturePressed,
    this.image,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.transparent),
      ),
      child: DottedBorder(
        borderPadding: const EdgeInsets.all(-10),
        borderType: BorderType.RRect,
        radius: const Radius.circular(20),
        color: AppColors.onSurface.withOpacity(0.2),
        strokeWidth: 1,
        dashPattern: const [6, 4],
        child: Column(
          spacing: 20,
          children: [
            if (image != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image(
                      image: FileImage(image!),
                    ),
                  ),
                  if (isLoading)
                    const Positioned.fill(
                      left: 5,
                      right: 5,
                      top: 5,
                      bottom: 5,
                      child: rive.RiveAnimation.asset(
                        'assets/riveAssets/qr_code_scanner.riv',
                        fit: BoxFit.fill,
                        artboard: 'scan_board',
                        animations: ['anim1'],
                        stateMachines: ['State Machine 1'],
                      ),
                    ),
                ],
              )
            else
              Icon(
                icon,
                size: 70,
                color: AppColors.onSurface.withOpacity(0.5),
              ),
            Text(
              titleDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt_outlined,
                      color: AppColors.primaryBlack),
                  label: Text(cameraButtonText, style: AppTextStyles.buttonTextBlack),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: AppColors.primaryWhite,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => onImageCapturePressed(ImageSource.camera),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.photo_library,
                      color: Theme.of(context).colorScheme.onPrimary),
                  label: Text(galleryButtonText, style: AppTextStyles.buttonTextWhite),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Theme.of(context).colorScheme.cardBackground,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onPressed: () => onImageCapturePressed(ImageSource.gallery),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
