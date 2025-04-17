import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/gen/assets.gen.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/viewmodels/meal_analysis_view_model.dart';
import 'package:read_the_label/views/common/primary_svg_picture.dart';
import 'package:read_the_label/views/widgets/food_nutreint_tile.dart';
import '../../models/food_item.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem item;
  final int index;

  const FoodItemCard({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
                color: Color(0xffC5E3D1),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                  ),
                  InkWell(
                    onTap: () => _showEditDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${item.quantity}${item.unit}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          PrimarySvgPicture(
                            Assets.icons.icEdit.path,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Nutrient grid
          GridView.count(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.0,
            children: [
              FoodNutrientTile(
                label: 'Calories',
                value: item
                        .calculateTotalNutrients()['calories']
                        ?.toStringAsFixed(1) ??
                    '0',
                unit: 'kcal',
                icon: Assets.icons.icCalories.path,
                color: const Color(0xff6BDE36),
              ),
              FoodNutrientTile(
                label: 'Protein',
                value: item
                        .calculateTotalNutrients()['protein']
                        ?.toStringAsFixed(1) ??
                    '0',
                unit: 'g',
                icon: Assets.icons.icProtein.path,
                color: const Color(0xffFFAF40),
              ),
              FoodNutrientTile(
                label: 'Carbohydrates',
                value: item
                        .calculateTotalNutrients()['carbohydrates']
                        ?.toStringAsFixed(1) ??
                    '0',
                unit: 'g',
                icon: Assets.icons.icCarbonHydrates.path,
                color: const Color(0xff6B25F6),
              ),
              FoodNutrientTile(
                label: 'Fat',
                value:
                    item.calculateTotalNutrients()['fat']?.toStringAsFixed(1) ??
                        '0',
                unit: 'g',
                icon: Assets.icons.icFat.path,
                color: const Color(0xffFF3F42),
              ),
              FoodNutrientTile(
                label: 'Fiber',
                value: item
                        .calculateTotalNutrients()['fiber']
                        ?.toStringAsFixed(1) ??
                    '0',
                unit: 'g',
                icon: Assets.icons.icFiber.path,
                color: const Color(0xff1CAE54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // In _showEditDialog method:

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: item.quantity.toString());

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Quantity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter Quantity in ${item.unit}',
                  hintStyle: const TextStyle(
                    color: Color(0xff6B6B6B),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Color(0xff6b6b6b)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppColors.green),
                  ),
                  filled: true,
                  fillColor: const Color(0xfff4f4f4),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    onPressed: () {
                      double? newQuantity = double.tryParse(controller.text);
                      if (newQuantity != null) {
                        item.quantity = newQuantity;
                        context
                            .read<MealAnalysisViewModel>()
                            .updateTotalNutrients();
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
