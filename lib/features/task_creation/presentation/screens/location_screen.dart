import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker_app/core/providers/task_creation_provider.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import '../../../../core/designs/app_colors.dart';
import '../../../../core/designs/widgets/primary_button.dart';

class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  String _selectedOption = 'current'; // current, search, map
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final draft = ref.read(taskCreationProvider);
    // if (draft.location != null) {
    //   _selectedOption = 'search';
    //   _addressController.text = draft.location!.address;
    // }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
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
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildOption(
                      'Use my current location',
                      Icons.my_location,
                      'current',
                      cardColor,
                      textColor,
                    ),
                    const SizedBox(height: 16),

                    _buildOption(
                      'Search address',
                      Icons.search,
                      'search',
                      cardColor,
                      textColor,
                    ),
                    if (_selectedOption == 'search') ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: _addressController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Enter address',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primary.withOpacity(0.5),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    _buildOption(
                      'Choose on Map',
                      Icons.map_outlined,
                      'map',
                      cardColor,
                      textColor,
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
                  String address = 'My Location';
                  if (_selectedOption == 'search' &&
                      _addressController.text.trim().isNotEmpty) {
                    address = _addressController.text.trim();
                  } else if (_selectedOption == 'map') {
                    address = 'Selected on Map';
                  }

                  // ref
                  //     .read(taskCreationProvider.notifier)
                  //     .updateLocation(
                  //       LocationModel(
                  //         address: address,
                  //         latitude: 0.0,
                  //         longitude: 0.0,
                  //       ),
                  //     );
                  context.pushNamed(RouteNames.taskSchedule.name);
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
    IconData icon,
    String value,
    Color cardColor,
    Color textColor,
  ) {
    final isSelected = _selectedOption == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedOption = value;
        });
      },
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
              icon,
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
}
