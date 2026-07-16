import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/designs/widgets/current_location.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import '../../../../core/designs/app_colors.dart';
import '../../../../core/designs/app_text_styles.dart';
import '../../../../core/designs/widgets/primary_button.dart';
import '../../../../core/providers/task_creation_provider.dart';
import '../../../../core/utils/num_extension.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _keepMinMaxSame = false;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(taskCreationProvider).value;
    if (draft?.budgetMin != null && draft!.budgetMin! > 0) {
      _minController.text = draft.budgetMin.toString();
    }
    if (draft?.budgetMax != null && draft!.budgetMax! > 0) {
      _maxController.text = draft.budgetMax.toString();
    }

    if (draft?.budgetMin != null &&
        draft?.budgetMax != null &&
        draft!.budgetMin == draft.budgetMax &&
        draft.budgetMin! > 0) {
      _keepMinMaxSame = true;
    }
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      final min =
          double.tryParse(
            _minController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          0.0;
      final max =
          double.tryParse(
            _maxController.text.replaceAll(RegExp(r'[^0-9.]'), ''),
          ) ??
          0.0;

      ref
          .read(taskCreationProvider.notifier)
          .updateBudget(
            min: min,
            max: _keepMinMaxSame ? min : max,
            pricingModel: 'fixed',
          );
      context.pushNamed(RouteNames.taskLocation.name);
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
        leading: CustomBackButton(),
        actions: [CurrentLocation()],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderWidget(textColor: textColor),
                      const SizedBox(height: 32),
                      _SameBudgetCheckbox(
                        value: _keepMinMaxSame,
                        textColor: textColor,
                        onChanged: (val) {
                          setState(() {
                            _keepMinMaxSame = val ?? false;
                            if (_keepMinMaxSame) {
                              _maxController.text = _minController.text;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      _BudgetField(
                        title: _keepMinMaxSame
                            ? 'Fixed Budget'
                            : 'Minimum Budget',
                        controller: _minController,
                        hint: 'e.g. ${20000.toNaira()}',
                        textColor: textColor,
                        cardColor: cardColor,
                        onChanged: _keepMinMaxSame
                            ? (val) {
                                _maxController.text = val;
                              }
                            : null,
                      ),
                      if (!_keepMinMaxSame) ...[
                        const SizedBox(height: 24),
                        _BudgetField(
                          title: 'Maximum Budget',
                          controller: _maxController,
                          hint: 'e.g. ${35000.toNaira()}',
                          textColor: textColor,
                          cardColor: cardColor,
                        ),
                      ],
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
      ),
    );
  }
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget({required this.textColor});
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'What\'s your budget?',
          style: AppTextStyles.heading1.copyWith(
            color: textColor,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Set a price range for this task. You can negotiate this later.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SameBudgetCheckbox extends StatelessWidget {
  const _SameBudgetCheckbox({
    required this.value,
    required this.onChanged,
    required this.textColor,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(
              color: AppColors.textSecondary.withOpacity(0.5),
              width: 1.5,
            ),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text(
              'Set a fixed budget',
              style: AppTextStyles.bodyMedium.copyWith(color: textColor),
            ),
          ),
        ),
      ],
    );
  }
}

class _BudgetField extends StatelessWidget {
  const _BudgetField({
    required this.title,
    required this.controller,
    required this.hint,
    required this.textColor,
    required this.cardColor,
    this.onChanged,
  });

  final String title;
  final TextEditingController controller;
  final String hint;
  final Color textColor;
  final Color cardColor;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          onChanged: onChanged,
          style: AppTextStyles.heading2.copyWith(color: textColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary.withOpacity(0.4),
              fontWeight: FontWeight.normal,
            ),
            prefixText: '₦ ',
            prefixStyle: AppTextStyles.heading2.copyWith(color: textColor),
            filled: true,
            fillColor: cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Required';
            if (double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ==
                null) {
              return 'Invalid amount';
            }
            return null;
          },
        ),
      ],
    );
  }
}
