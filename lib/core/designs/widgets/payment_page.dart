import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/clients/clients.dart';
import 'package:seeker_app/core/utils/flushbar_message.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';

import '../../constants.dart';
import '../../utils/loading_overlay.dart';
import '../app_colors.dart';

// ──────────────────────────────────────────────
// Models
// ──────────────────────────────────────────────

/// Result returned by [PaymentPage.show].
class PaymentInfo {
  /// Whether the payment completed successfully.
  final bool isSuccessful;

  /// The amount that was paid.
  final double amount;

  const PaymentInfo({required this.isSuccessful, required this.amount});

  @override
  String toString() =>
      'PaymentInfo(isSuccessful: $isSuccessful, amount: $amount)';
}

// ──────────────────────────────────────────────
// Test data
// ──────────────────────────────────────────────

class _TestCard {
  final String label;
  final String cardNumber;
  final String expiry;
  final String cvv;
  final String holderName;

  const _TestCard({
    required this.label,
    required this.cardNumber,
    required this.expiry,
    required this.cvv,
    required this.holderName,
  });
}

const _testCards = [
  _TestCard(
    label: 'Visa – Success',
    cardNumber: '4111 1111 1111 1111',
    expiry: '12/28',
    cvv: '123',
    holderName: 'John Doe',
  ),
  _TestCard(
    label: 'Mastercard',
    cardNumber: '5500 0000 0000 0004',
    expiry: '06/27',
    cvv: '456',
    holderName: 'Jane Smith',
  ),
];

// ──────────────────────────────────────────────
// Widget
// ──────────────────────────────────────────────

class PaymentPage extends ConsumerStatefulWidget {
  /// Pre-filled amount. User can still edit it if null.
  final double? amount;
  final String? userId;
  final String? taskId;

  const PaymentPage({super.key, this.amount, this.userId, this.taskId});

  /// Show the payment bottom sheet and return the result.
  static Future<PaymentInfo> show({double? amount, String? userId, String? taskId}) async {
    final context = rootNavigatorKey.currentContext!;

    final result = await showModalBottomSheet<PaymentInfo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: PaymentPage(amount: amount, userId: userId, taskId: taskId),
      ),
    );

    // If user dismisses without paying, return a failed result.
    return result ?? PaymentInfo(isSuccessful: false, amount: amount ?? 0);
  }

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  // Card fields
  final _cardNumberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _holderNameCtrl = TextEditingController();

  // Amount
  final _amountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.amount != null) {
      _amountCtrl.text = widget.amount!.toStringAsFixed(2);
    }
    _amountCtrl.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _amountCtrl.removeListener(_onAmountChanged);
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _holderNameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──

  void _fillCard(_TestCard card) {
    setState(() {
      _cardNumberCtrl.text = card.cardNumber;
      _expiryCtrl.text = card.expiry;
      _cvvCtrl.text = card.cvv;
      _holderNameCtrl.text = card.holderName;
    });
  }

  double get _amount => double.tryParse(_amountCtrl.text) ?? 0;

  Future<void> _onPayNow() async {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid amount',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    // Show loading overlay
    if (!mounted) return;
    context.showLoading();

    try {
      final paymentsClient = ref.read(paymentsClientProvider);
      final payload = WebhookPayload.payment(
        _amount.toInt(),
        userId: widget.userId,
        taskId: widget.taskId,
      );

      final response = await paymentsClient.processPaymentWebhook(payload);

      if (!mounted) return;
      context.hideLoading();

      if (response.success) {
        final info = PaymentInfo(isSuccessful: true, amount: _amount);
        Navigator.of(context).pop(info);
      } else {
        context.showMessage(
          response.detail ?? "Unable to process payment",
          type: MessageType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      context.hideLoading();
      context.showMessage(
        "Unable to process payment",
        type: MessageType.error,
      );
    }
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: 16.h,
        bottom: 32.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: _buildDragHandle(isDark)),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Card Payment',
                    style: AppTextStyles.heading3.copyWith(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 20.sp,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please provide your payment details. Transactions are securely processed.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    _buildAmountField(colorScheme, isDark),
                    SizedBox(height: 20.h),
                    _buildTestCardSelector(colorScheme, isDark),
                    SizedBox(height: 16.h),
                    _buildCardForm(colorScheme, isDark),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 0),
              child: _buildPayButton(colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle(bool isDark) {
    return Container(
      width: 48.w,
      height: 5.h,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.2)
            : Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2.5.r),
      ),
    );
  }

  // ── Amount Field ──

  Widget _buildAmountField(ColorScheme colorScheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Amount (₦)', colorScheme),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _amountCtrl,
          readOnly: widget.amount != null,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          style: GoogleFonts.inter(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface.withValues(alpha: 0.15),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 12.w, right: 4.w),
              child: Text(
                '₦',
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            filled: true,
            fillColor: colorScheme.onSurface.withValues(alpha: 0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16.h),
          ),
        ),
      ],
    );
  }

  // ── Card Form ──

  Widget _buildTestCardSelector(ColorScheme colorScheme, bool isDark) {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _testCards.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final card = _testCards[i];
          return GestureDetector(
            onTap: () => _fillCard(card),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Text(
                card.label,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardForm(ColorScheme colorScheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _styledInput(
          controller: _cardNumberCtrl,
          hint: 'Card Number',
          colorScheme: colorScheme,
          keyboardType: TextInputType.number,
          formatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d ]')),
            LengthLimitingTextInputFormatter(23),
            _CardNumberFormatter(),
          ],
          prefixIcon: _cardBrandIcon(),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _styledInput(
                controller: _expiryCtrl,
                hint: 'MM/YY',
                colorScheme: colorScheme,
                keyboardType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d/]')),
                  LengthLimitingTextInputFormatter(5),
                  _ExpiryFormatter(),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _styledInput(
                controller: _cvvCtrl,
                hint: 'CVV',
                colorScheme: colorScheme,
                keyboardType: TextInputType.number,
                obscure: true,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _cardBrandIcon() {
    final number = _cardNumberCtrl.text.replaceAll(' ', '');
    IconData icon = Icons.credit_card_rounded;
    Color color = Colors.grey;

    if (number.startsWith('4')) {
      icon = Icons.credit_card;
      color = const Color(0xFF1A1F71); // Visa blue
    } else if (number.startsWith('5')) {
      icon = Icons.credit_card;
      color = const Color(0xFFEB001B); // Mastercard red
    }

    return Padding(
      padding: EdgeInsets.only(left: 12.w, right: 8.w),
      child: Icon(icon, size: 20.sp, color: color),
    );
  }

  // ── Pay Button ──

  Widget _buildPayButton(ColorScheme colorScheme) {
    return PrimaryButton(
      text: _amount > 0 ? 'Pay ₦${_amount.toStringAsFixed(2)}' : 'Pay Now',
      onPressed: _onPayNow,
    );
  }

  // ──────────────────────────────────────────────
  // Shared small widgets
  // ──────────────────────────────────────────────

  Widget _fieldLabel(String text, ColorScheme colorScheme) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _styledInput({
    required TextEditingController controller,
    required String hint,
    required ColorScheme colorScheme,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    bool obscure = false,
    Widget? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      obscureText: obscure,
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        prefixIcon: prefixIcon,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: colorScheme.onSurface.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Input formatters
// ──────────────────────────────────────────────

/// Formats a card number as groups of four: `1234 5678 9012 3456`.
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formats expiry as `MM/YY`.
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length && i < 4; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
