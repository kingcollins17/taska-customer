import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker_app/core/providers/task_creation_provider.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import '../../../../core/designs/app_colors.dart';
import '../../../../core/designs/widgets/primary_button.dart';

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
  DateTime? _customExpirationDate;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(taskCreationProvider);
    // if (draft.startAt != null) {
    //   _asSoonAsPossible = false;
    //   _selectedDate = draft.startAt;
    //   _selectedTime = TimeOfDay.fromDateTime(draft.startAt!);
    // }
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Skip schedule
              context.push('/task-creation/review');
            },
            child: Text(
              'Skip',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.2,
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'When should this task stop accepting offers?',
                      style: TextStyle(
                        fontSize: 14,
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: PrimaryButton(
                text: 'Continue',
                onPressed: () {
                  DateTime? startAt;
                  if (!_asSoonAsPossible &&
                      _selectedDate != null &&
                      _selectedTime != null) {
                    startAt = DateTime(
                      _selectedDate!.year,
                      _selectedDate!.month,
                      _selectedDate!.day,
                      _selectedTime!.hour,
                      _selectedTime!.minute,
                    );
                  }

                  DateTime expiresAt = DateTime.now();
                  if (_expirationOption == '3 days')
                    expiresAt = expiresAt.add(const Duration(days: 3));
                  else if (_expirationOption == '5 days')
                    expiresAt = expiresAt.add(const Duration(days: 5));
                  else if (_expirationOption == '1 week')
                    expiresAt = expiresAt.add(const Duration(days: 7));
                  else if (_expirationOption == 'Custom' &&
                      _customExpirationDate != null)
                    expiresAt = _customExpirationDate!;
                  else
                    expiresAt = expiresAt.add(
                      const Duration(days: 3),
                    ); // Fallback

                  ref
                      .read(taskCreationProvider.notifier)
                      .updateSchedule(startAt: startAt, expiresAt: expiresAt);
                  context.pushNamed(RouteNames.taskReview.name);
                },
              ),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
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
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
          style: TextStyle(
            color: isSelected ? Colors.white : textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
