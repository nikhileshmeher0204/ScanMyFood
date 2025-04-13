import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/viewmodels/product_analysis_view_model.dart';
import 'package:read_the_label/views/common/primary_button.dart';
import 'package:read_the_label/views/screens/scan_lable/scan_lable_result.dart';

import '../../../main.dart';

class ProductScanPage extends StatefulWidget {
  const ProductScanPage({super.key});

  @override
  State<ProductScanPage> createState() => _ProductScanPageState();
}

class _ProductScanPageState extends State<ProductScanPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 32,
        right: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.asset(
            Assets.images.imScanLable.path,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 48),
          Text(
            'To Get Started, Scan Product Front Or\nChoose From Gallery!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Scan Now',
            onPressed: () => _handleImageCapture(ImageSource.camera),
            iconPath: Assets.icons.icScan.path,
            backgroundColor: Theme.of(context).colorScheme.primary,
            borderRadius: 30,
            margin: const EdgeInsets.symmetric(horizontal: 30),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            width: 240,
            text: 'Gallery',
            onPressed: () => _handleImageCapture(ImageSource.gallery),
            iconPath: Assets.icons.icGallery.path,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            borderRadius: 30,
            margin: const EdgeInsets.symmetric(horizontal: 30),
          ),
        ],
      ),
    );
  }

  void _handleImageCapture(ImageSource source) async {
    // First, capture front image
    final productAnalysisProvider =
        Provider.of<ProductAnalysisViewModel>(context, listen: false);

    await productAnalysisProvider.captureImage(
      source: source,
      isFrontImage: true,
    );

    if (productAnalysisProvider.frontImage != null) {
      // Show dialog for nutrition label
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Now capture nutrition label',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'Poppins'),
            ),
            content: Text(
              'Please capture or select the nutrition facts label of the product',
              style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontFamily: 'Poppins'),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await productAnalysisProvider.captureImage(
                    source: source,
                    isFrontImage: false,
                  );
                  if (productAnalysisProvider.canAnalyze()) {
                    Navigator.push(
                        navKey.currentContext!,
                        MaterialPageRoute(
                          builder: (context) => const ScanLableResultPage(),
                        ));
                  }
                },
                child: const Text('Continue',
                    style: TextStyle(fontFamily: 'Poppins')),
              ),
            ],
          ),
        );
      }
    }
  }
}
