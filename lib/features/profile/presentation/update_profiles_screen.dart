import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seeker_app/core/designs/widgets/custom_back_button.dart';
import 'package:seeker_app/core/designs/widgets/custom_text_field.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/user_provider.dart';
import 'package:seeker_app/core/utils/flushbar_message.dart';
import 'package:seeker_app/core/utils/loading_overlay.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  ConsumerState<UpdateProfileScreen> createState() =>
      _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends ConsumerState<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _populateUserFields(User? user) {
    if (!_initialized && user != null) {
      _firstNameController.text = user.customerProfile?.firstName ?? '';
      _lastNameController.text = user.customerProfile?.lastName ?? '';
      _initialized = true;
    }
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    try {
      context.showLoading();

      await ref.read(userProvider.notifier).updateProfile(
            request: UpdateProfileRequest(
              firstName: firstName,
              lastName: lastName,
            ),
            onSuccess: () {
              if (!mounted) return;
              context.hideLoading();
              context.showMessage(
                'Profile updated successfully',
                type: MessageType.success,
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.pop();
                }
              });
            },
            onError: (msg) {
              if (!mounted) return;
              context.hideLoading();
              context.showMessage(msg, type: MessageType.error);
            },
          );
    } catch (e) {
      if (!mounted) return;
      context.hideLoading();
      context.showMessage(
        'Failed to update profile: $e',
        type: MessageType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final userState = ref.watch(userProvider);
    final user = userState.value;

    _populateUserFields(user);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Text(
          'Update Profile',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form Section Header
                Text(
                  'Personal Information',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 24.h),

                // First Name Label & Input
                Text(
                  'First Name',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: _firstNameController,
                  hintText: 'Enter first name',
                  leadingIcon: Icons.person_outline,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Last Name Label & Input
                Text(
                  'Last Name',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  controller: _lastNameController,
                  hintText: 'Enter last name',
                  leadingIcon: Icons.person_outline,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
          child: PrimaryButton(
            text: 'Save Changes',
            onPressed: _handleSave,
          ),
        ),
      ),
    );
  }
}
