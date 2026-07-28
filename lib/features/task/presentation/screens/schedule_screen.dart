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
    DateTime expiresAt = baseTime.add(const Duration(days: 3));

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
                      'When do you need this done?',
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
}
