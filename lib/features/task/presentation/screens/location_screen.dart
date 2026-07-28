import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/designs/widgets/current_location.dart';
import 'package:seeker_app/core/providers/location_provider.dart';
import 'package:seeker_app/core/providers/task_creation_provider.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'package:seeker_app/core/models/tasks/task.dart';
import '../../../../core/designs/app_colors.dart';
import '../../../../core/designs/app_text_styles.dart';
import '../../../../core/designs/widgets/primary_button.dart';
import '../../../../core/designs/widgets/custom_back_button.dart';

class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  String _selectedOption = 'current'; // current, map
  bool _isLoading = false;

  void _onContinue() async {
    if (_selectedOption == 'map') {
      // Show snackbar that it's coming soon
      context.showMessage(
        'Map selection is coming soon!',
        type: MessageType.info,
      );
      return;
    }

    if (_selectedOption == 'current') {
      setState(() {
        _isLoading = true;
      });

      final address = await ref.read(locationProvider.future);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (address != null) {
        final locationRequest = CreateTaskLocationRequest(
          locationType: 'service', // single service location
          latitude: address.lat,
          longitude: address.lng,
          address: address.formattedAddress ?? address.street ?? 'My Location',
          city: address.city,
          state: address.state,
          country: address.country,
        );

        ref.read(taskCreationProvider.notifier).updateLocation(locationRequest);
        context.pushNamed(RouteNames.taskSchedule.name);
      } else {
        context.showMessage(
          'Could not determine current location. Please ensure location services are enabled.',
          type: MessageType.error,
        );
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
                      'Where should the task be done?',
                      style: AppTextStyles.heading1.copyWith(
                        color: textColor,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Choose how you want to provide your location.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildOption(
                      text: 'Use my current location',
                      icon: Icons.my_location,
                      value: 'current',
                      cardColor: cardColor,
                      textColor: textColor,
                    ),
                    const SizedBox(height: 16),

                    _buildOption(
                      text: 'Choose on Map',
                      icon: Icons.map_outlined,
                      value: 'map',
                      cardColor: cardColor,
                      textColor: textColor,
                      isDisabled: true,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: PrimaryButton(
                text: 'Continue',
                isLoading: _isLoading,
                onPressed: _onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required String text,
    required IconData icon,
    required String value,
    required Color cardColor,
    required Color textColor,
    bool isDisabled = false,
  }) {
    final isSelected = _selectedOption == value;
    final effectiveTextColor = isDisabled ? AppColors.textSecondary : textColor;
    final iconColor = isDisabled
        ? AppColors.textSecondary.withOpacity(0.5)
        : (isSelected ? AppColors.primary : AppColors.textSecondary);
    final borderColor = (isSelected && !isDisabled)
        ? AppColors.primary
        : Colors.transparent;
    final effectiveCardColor = isDisabled
        ? cardColor.withOpacity(0.5)
        : cardColor;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedOption = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: effectiveCardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: effectiveTextColor,
                    ),
                  ),
                  if (isDisabled) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Coming Soon',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
