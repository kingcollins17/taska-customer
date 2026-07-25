import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seeker_app/core/designs/widgets/widgets.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/user_provider.dart';
import 'package:seeker_app/core/utils/flushbar_message.dart';
import 'package:seeker_app/core/utils/loading_overlay.dart';
import 'package:shimmer/shimmer.dart';

class UpdatePayoutAccountScreen extends ConsumerStatefulWidget {
  const UpdatePayoutAccountScreen({super.key});

  @override
  ConsumerState<UpdatePayoutAccountScreen> createState() =>
      _UpdatePayoutAccountScreenState();
}

class _UpdatePayoutAccountScreenState
    extends ConsumerState<UpdatePayoutAccountScreen> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  SupportedBank? _selectedBank;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _accountController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _accountController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedBank == null || _selectedBank!.bankCode == null) {
      context.showMessage(
        'Please select a valid bank',
        type: MessageType.error,
      );
      return;
    }

    try {
      context.showLoading();

      // 1. Verify bank account
      final verifiedDetails = await ref.read(
        verifyBankAccountProvider((
          accountNumber: _accountController.text.trim(),
          bankCode: _selectedBank!.bankCode!,
        )).future,
      );

      if (!mounted) return;

      // 2. Update payout account
      await ref
          .read(userProvider.notifier)
          .updatePayoutAccount(
            payload: PayoutAccountPayload(
              bankCode: _selectedBank!.bankCode,
              bankName: _selectedBank!.name,
              accountName: verifiedDetails.accountName,
              accountNumber: verifiedDetails.accountNumber,
            ),
            onSuccess: () {
              context.hideLoading();
              context.showMessage(
                'Payout account updated successfully',
                type: MessageType.success,
              );
              Navigator.pop(context);
            },
            onError: (msg) {
              context.hideLoading();
              context.showMessage(msg, type: MessageType.error);
            },
          );
    } catch (e) {
      context.hideLoading();
      context.showMessage(
        'Failed to update account: $e',
        type: MessageType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Text(
          'Update Payout Account',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bank Information',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Select your bank and enter your account number to receive payouts.',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 24.h),
              CustomTextField(
                controller: _bankController,
                hintText: 'Select Bank',
                readOnly: true,
                leadingIcon: Icons.account_balance,
                suffix: Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                onTap: () async {
                  final selected = await SelectBank.select(context);
                  if (selected != null) {
                    setState(() {
                      _selectedBank = selected;
                      _bankController.text = selected.name ?? '';
                    });
                  }
                },
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Bank is required' : null,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: _accountController,
                hintText: 'Account Number',
                leadingIcon: Icons.numbers,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Account number is required';
                  }
                  if (val.length != 10) {
                    return 'Account number must be 10 digits';
                  }
                  return null;
                },
              ),
              _VerifiedBankSection(
                selectedBank: _selectedBank,
                accountNumber: _accountController.text,
              ),
              SizedBox(height: 48.h),
              PrimaryButton(text: 'Update Account', onPressed: _handleUpdate),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerifiedBankSection extends ConsumerWidget {
  final SupportedBank? selectedBank;
  final String accountNumber;

  const _VerifiedBankSection({
    required this.selectedBank,
    required this.accountNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountNo = accountNumber.trim();
    if (selectedBank == null ||
        selectedBank!.bankCode == null ||
        accountNo.length < 10) {
      return const SizedBox.shrink();
    }

    final verifyAsync = ref.watch(
      verifyBankAccountProvider((
        accountNumber: accountNo,
        bankCode: selectedBank!.bankCode!,
      )),
    );

    final colorScheme = Theme.of(context).colorScheme;

    return verifyAsync.when(
      data: (details) => Container(
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.only(top: 16.h),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: colorScheme.primary),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Verified Account Name',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    details.accountName ?? 'Unknown',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => Shimmer.fromColors(
        baseColor: colorScheme.onSurface.withValues(alpha: 0.1),
        highlightColor: colorScheme.onSurface.withValues(alpha: 0.05),
        child: Container(
          height: 64.h,
          margin: EdgeInsets.only(top: 16.h),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
      error: (err, st) => Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: Text(
          'Could not verify account',
          style: GoogleFonts.inter(color: colorScheme.error, fontSize: 12.sp),
        ),
      ),
    );
  }
}
