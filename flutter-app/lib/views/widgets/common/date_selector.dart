import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_the_label/theme/app_colors.dart';
import 'package:read_the_label/theme/app_text_styles.dart';
import 'package:read_the_label/viewmodels/ui_view_model.dart';

/// A date selector that mirrors the exact look and feel of [TimeSelector].
///
/// **Uncontrolled** (no props) — tappable card row that opens a Cupertino
/// bottom sheet with fixed date options (Today, Yesterday, and 12 older dates).
/// Reads/writes [UiViewModel.selectedDate]. Used in [TotalNutrientsCard].
///
/// **Controlled** (props passed) — renders the chips inline without a card
/// wrapper. Used by [DateSectionWidget] in the history view.
class DateSelector extends StatelessWidget {
  const DateSelector({
    super.key,
    this.selectedDate,
    this.onDateSelected,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;

  static const int _totalDays = 14;

  // ── Helpers ──────────────────────────────────────────────────────────

  static String labelFor(DateTime date, DateTime today) {
    final todayDate = DateTime(today.year, today.month, today.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final diff = todayDate.difference(targetDate).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';

    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  /// Opens the date picker sheet — identical shell to [TimeSelector].
  void _showDatePicker(BuildContext context) {
    final uiViewModel = Provider.of<UiViewModel>(context, listen: false);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final dates = List.generate(
      _totalDays,
      (i) => DateTime(todayDate.year, todayDate.month, todayDate.day - i),
    );

    // Clamp initial value to valid range.
    final selectedDate = DateTime(
      uiViewModel.selectedDate.year,
      uiViewModel.selectedDate.month,
      uiViewModel.selectedDate.day,
    );
    final selectedDiff = todayDate.difference(selectedDate).inDays;
    final initialIndex = selectedDiff.clamp(0, _totalDays - 1).toInt();
    DateTime tempDate = dates[initialIndex];
    final scrollController =
        FixedExtentScrollController(initialItem: initialIndex);

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext ctx) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // ── Header bar — identical to TimeSelector ─────────────
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.secondaryBlackTextColor,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.withColor(
                          AppTextStyles.bodyMedium,
                          AppColors.textSecondary,
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    CupertinoButton(
                      child: Text(
                        'Done',
                        style: AppTextStyles.withColor(
                          AppTextStyles.withWeight(
                            AppTextStyles.bodyMedium,
                            FontWeight.w600,
                          ),
                          AppColors.secondaryGreen,
                        ),
                      ),
                      onPressed: () {
                        uiViewModel.updateSelectedDate(tempDate);
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              ),

              // ── Fixed date options: Today, Yesterday, and 12 older dates ──
              Expanded(
                child: CupertinoPicker(
                  backgroundColor: AppColors.cardBackground,
                  itemExtent: 44,
                  scrollController: scrollController,
                  onSelectedItemChanged: (int index) {
                    tempDate = dates[index];
                  },
                  children: dates
                      .map(
                        (date) => Center(
                          child: Text(
                            labelFor(date, todayDate),
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.primaryWhite,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    // ── Controlled mode (inline chips, no card) ─────────────────────
    if (selectedDate != null && onDateSelected != null) {
      final dates = List.generate(
        _totalDays,
        (i) => DateTime(today.year, today.month, today.day - i),
      );
      final selectedDay = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
      );

      return SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: dates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, index) {
            final date = dates[index];
            final dateDay = DateTime(date.year, date.month, date.day);
            final isSelected = dateDay == selectedDay;
            final label = labelFor(date, today);

            return GestureDetector(
              onTap: () => onDateSelected!(date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryWhite
                      : AppColors.primaryBlack,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryWhite
                        : AppColors.secondaryBlackTextColor.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primaryBlack
                        : AppColors.secondaryBlackTextColor,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontFamily: AppTextStyles.fontFamily,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    // ── Uncontrolled mode (card row, same as TimeSelector) ──────────
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Selector<UiViewModel, DateTime>(
        selector: (_, vm) => vm.selectedDate,
        builder: (context, selected, _) {
          return CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showDatePicker(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              width: double.infinity,
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.secondaryBlackTextColor,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Date',
                    style: AppTextStyles.withColor(
                      AppTextStyles.heading4,
                      AppColors.primaryWhite,
                    ),
                  ),
                  const Spacer(),
                  // ── Date label (Today / Yesterday / formatted) ────
                  RichText(
                    text: TextSpan(
                      children: _buildDateTextSpans(selected, today),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.secondaryBlackTextColor,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds styled text spans for the selected date label,
  /// mirroring [UiViewModel.buildTimeTextSpans].
  List<TextSpan> _buildDateTextSpans(DateTime selected, DateTime today) {
    final label = labelFor(selected, today);

    // "Today" / "Yesterday" → single span
    if (label == 'Today' || label == 'Yesterday') {
      return [
        TextSpan(
          text: label,
          style: const TextStyle(
            color: AppColors.primaryWhite,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ),
      ];
    }

    // "Mon, Jun 3" → split on comma: day-name dimmed, rest bright
    final commaIdx = label.indexOf(',');
    if (commaIdx != -1) {
      return [
        TextSpan(
          text: label.substring(0, commaIdx + 1),
          style: const TextStyle(
            color: AppColors.secondaryBlackTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ),
        TextSpan(
          text: label.substring(commaIdx + 1),
          style: const TextStyle(
            color: AppColors.primaryWhite,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ),
      ];
    }

    return [
      TextSpan(
        text: label,
        style: const TextStyle(
          color: AppColors.primaryWhite,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          fontFamily: AppTextStyles.fontFamily,
        ),
      ),
    ];
  }
}
