import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker_app/core/designs/widgets/current_location.dart';
import 'package:seeker_app/core/providers/task_creation_provider.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import '../../../../core/designs/app_colors.dart';
import '../../../../core/designs/app_text_styles.dart';
import '../../../../core/designs/widgets/primary_button.dart';
import '../../../../core/designs/widgets/custom_back_button.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  bool _asSoonAsPossible = true;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String _expirationOption = '3 days'; // '3 days', '5 days', '1 week', 'Custom'
  final _customDaysController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final draft = ref.read(taskCreationProvider).value;
    if (draft?.scheduledStartAt != null) {
      _asSoonAsPossible = false;
      _selectedDate = draft!.scheduledStartAt;
      _selectedTime = TimeOfDay.fromDateTime(draft.scheduledStartAt!);
    }
  }

  @override
  void dispose() {
    _customDaysController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
      );
      if (time != null && mounted) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
          _asSoonAsPossible = false;
        });
      }
    }
  }

  void _onContinue() {
    DateTime? startAt;
    if (!_asSoonAsPossible && _selectedDate != null && _selectedTime != null) {
      startAt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }

    DateTime baseTime = startAt ?? DateTime.now();
    DateTime expiresAt;

    if (_expirationOption == '3 days') {
      expiresAt = baseTime.add(const Duration(days: 3));
    } else if (_expirationOption == '5 days') {
      expiresAt = baseTime.add(const Duration(days: 5));
    } else if (_expirationOption == '1 week') {
      expiresAt = baseTime.add(const Duration(days: 7));
    } else if (_expirationOption == 'Custom') {
      int customDays = int.tryParse(_customDaysController.text.trim()) ?? 3;
      if (customDays < 1) customDays = 1;
      expiresAt = baseTime.add(Duration(days: customDays));
    } else {
      expiresAt = baseTime.add(const Duration(days: 3)); // Fallback
    }

    ref
        .read(taskCreationProvider.notifier)
        .updateSchedule(startAt: startAt, expiresAt: expiresAt);
    context.pushNamed(RouteNames.taskReview.name);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final cardColor = isDark ? AppColors.darkerBackground : AppColors.surface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: const CustomBackButton(),
        actions: [CurrentLocation()],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'When should it start?',
                      style: AppTextStyles.heading1.copyWith(
                        color: textColor,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildOption(
                      'As soon as possible',
                      _asSoonAsPossible,
                      () {
                        setState(() {
                          _asSoonAsPossible = true;
                        });
                      },
                      cardColor,
                      textColor,
                    ),
                    const SizedBox(height: 16),

                    _buildOption(
                      _selectedDate != null &&
                              _selectedTime != null &&
                              !_asSoonAsPossible
                          ? 'Starts: ${_selectedDate!.month}/${_selectedDate!.day} at ${_selectedTime!.format(context)}'
                          : 'Pick date & time',
                      !_asSoonAsPossible,
                      _pickDateTime,
                      cardColor,
                      textColor,
                    ),

                    const SizedBox(height: 48),
                    Text(
                      'Expiration',
                      style: AppTextStyles.heading2.copyWith(color: textColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'When should this task stop accepting offers?',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildChip('3 days', textColor, cardColor),
                        _buildChip('5 days', textColor, cardColor),
                        _buildChip('1 week', textColor, cardColor),
                        _buildChip('Custom', textColor, cardColor),
                      ],
                    ),

                    if (_expirationOption == 'Custom') ...[
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _customDaysController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: AppTextStyles.heading2.copyWith(
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. 10',
                          hintStyle: AppTextStyles.heading3.copyWith(
                            color: AppColors.textSecondary.withOpacity(0.4),
                            fontWeight: FontWeight.normal,
                          ),
                          filled: true,
                          fillColor: cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(20),
                          suffixText: 'days',
                          suffixStyle: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: PrimaryButton(text: 'Continue', onPressed: _onContinue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    String text,
    bool isSelected,
    VoidCallback onTap,
    Color cardColor,
    Color textColor,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color textColor, Color cardColor) {
    final isSelected = _expirationOption == label;
    return InkWell(
      onTap: () {
        setState(() {
          _expirationOption = label;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
