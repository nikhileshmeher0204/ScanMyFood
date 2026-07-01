import 'dart:io';
import 'package:flutter/material.dart';
import 'package:read_the_label/models/food_nutrient.dart';
import 'package:read_the_label/models/quantity.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/base_view_model.dart';

class UiViewModel extends BaseViewModel {
  // UI state
  double _servingSize = 0.0;
  double _sliderValue = 0.0;
  int _currentIndex = 0;
  bool _isLoading = false;
  DateTime _selectedTime = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  double _portionMultiplier = 1.0; // Add portion state

  int get currentIndex => _currentIndex;
  double get servingSize => _servingSize;
  double get sliderValue => _sliderValue;
  bool get loading => _isLoading;
  DateTime get selectedTime => _selectedTime;
  DateTime get selectedDate => _selectedDate;
  double get portionMultiplier => _portionMultiplier; // Add getter

  final Map<String, Future<Color>> _dominantColorCache = {};

  Future<Color> extractDominantColor(String? imagePathOrUrl) {
    if (imagePathOrUrl == null || imagePathOrUrl.isEmpty) {
      return Future.value(Colors.black.withValues(alpha: 0.3));
    }

    if (_dominantColorCache.containsKey(imagePathOrUrl)) {
      return _dominantColorCache[imagePathOrUrl]!;
    }

    final future = _performColorExtraction(imagePathOrUrl);
    _dominantColorCache[imagePathOrUrl] = future;
    return future;
  }

  Future<Color> _performColorExtraction(String imagePathOrUrl) async {
    try {
      final ImageProvider imageProvider;
      if (imagePathOrUrl.startsWith('http') ||
          imagePathOrUrl.startsWith('https')) {
        imageProvider = NetworkImage(imagePathOrUrl);
      } else if (imagePathOrUrl.startsWith('assets/')) {
        imageProvider = AssetImage(imagePathOrUrl);
      } else {
        imageProvider = FileImage(File(imagePathOrUrl));
      }

      final colorScheme = await ColorScheme.fromImageProvider(
        provider: imageProvider,
        brightness: Brightness.light,
      );

      // ─── Tuning knobs ────────────────────────────────────────────────
      // Apple Music keeps backgrounds dark but vivid.
      // Raise saturation to get closer to the source image's true color.
      const double targetLightness =
          0.18; // 0.0 (black) → 1.0 (white). Apple ≈ 0.15–0.22
      const double targetSaturation =
          0.95; // 0.0 (grey) → 1.0 (full chroma). Apple ≈ 0.65–0.85
      // ─────────────────────────────────────────────────────────────────

      final seedColor = colorScheme.primary;
      final hsl = HSLColor.fromColor(seedColor);

      // Clamp original saturation upward — never reduce a naturally vivid color.
      final boostedSaturation = hsl.saturation.clamp(targetSaturation, 1.0);

      final darkBackground = hsl
          .withSaturation(boostedSaturation)
          .withLightness(targetLightness)
          .toColor();

      return darkBackground;
    } catch (e) {
      debugPrint("Error extracting color from image: $e");
      return Colors.black.withValues(alpha: 0.3);
    }
  }

  void setLoading(bool loading) {
    print("UiProvider: Setting loading to $loading");
    _isLoading = loading;
    notifyListeners();
  }

  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void updateServingSize(double size) {
    _servingSize = size;
    print(_servingSize);
    notifyListeners();
  }

  void updateSliderValue(double value) {
    _sliderValue = value;
    notifyListeners();
  }

  void updateSelectedTime(DateTime time) {
    _selectedTime = time;
    notifyListeners();
  }

  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Combines the selected date and time into a single DateTime for submission.
  DateTime get selectedDateTime => DateTime(
    _selectedDate.year,
    _selectedDate.month,
    _selectedDate.day,
    _selectedTime.hour,
    _selectedTime.minute,
  );

  void updatePortionMultiplier(double multiplier) {
    _portionMultiplier = multiplier;
    notifyListeners();
  }

  // Helper method to calculate adjusted nutrients
  List<FoodNutrient> calculateAdjustedNutrients(
    List<FoodNutrient> originalNutrients,
  ) {
    final List<FoodNutrient> result = [];
    for (var nutrient in originalNutrients) {
      // Create new FoodNutrient with adjusted value but same unit
      result.add(
        FoodNutrient(
          name: nutrient.name,
          quantity: Quantity(
            value: nutrient.quantity.value * _portionMultiplier,
            unit: nutrient.quantity.unit,
          ),
        ),
      );
    }
    return result;
  }

  Color getColorForPercent(double percent) {
    if (percent > 1.0) return Colors.red; // Exceeded daily value
    if (percent > 0.8) return Colors.green; // High but not exceeded
    if (percent > 0.6) return Colors.yellow; // Moderate
    if (percent > 0.4) return Colors.yellow; // Low to moderate
    return Colors.green; // Low
  }

  IconData getNutrientIcon(String nutrient) {
    switch (nutrient.toLowerCase()) {
      case 'energy':
        return Icons.bolt;
      case 'protein':
        return Icons.fitness_center;
      case 'carbohydrate':
        return Icons.grain;
      case 'fat':
        return Icons.opacity;
      case 'fiber':
        return Icons.grass;
      case 'sodium':
        return Icons.water_drop;
      case 'calcium':
        return Icons.shield;
      case 'iron':
        return Icons.architecture;
      case 'vitamin':
        return Icons.brightness_high;
      default:
        return Icons.science;
    }
  }

  String getFormattedTime() {
    final hour = _selectedTime.hour == 0
        ? 12
        : (_selectedTime.hour > 12
              ? _selectedTime.hour - 12
              : _selectedTime.hour);
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    final period = _selectedTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  List<TextSpan> buildTimeTextSpans() {
    final timeString = getFormattedTime();
    final parts = timeString.split(' ');
    List<TextSpan> spans = [];

    if (parts.length >= 2) {
      // Time part (HH:MM)
      spans.add(
        TextSpan(
          text: "${parts[0]} ",
          style: const TextStyle(
            color: AppColors.primaryWhite,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ),
      );

      // AM/PM part
      spans.add(
        TextSpan(
          text: parts[1],
          style: const TextStyle(
            color: AppColors.secondaryBlackTextColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ),
      );
    }

    return spans;
  }
}
