import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/clients/clients.dart';
import 'package:seeker_app/core/providers/task_providers.dart';
import 'package:seeker_app/core/utils/flushbar_message.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';

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
  static Future<PaymentInfo> show({
    double? amount,
    String? userId,
    String? taskId,
  }) async {
    final completer = Completer<PaymentInfo>();

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      if (!completer.isCompleted) {
        completer.complete(
          PaymentInfo(isSuccessful: false, amount: amount ?? 0),
        );
      }
      return completer.future;
    }

    try {
      final result = await showModalBottomSheet<PaymentInfo>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (_) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: PaymentPage(amount: amount, userId: userId, taskId: taskId),
        ),
      );

      if (!completer.isCompleted) {
        completer.complete(
          result ?? PaymentInfo(isSuccessful: false, amount: amount ?? 0),
        );
      }
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(
          PaymentInfo(isSuccessful: false, amount: amount ?? 0),
        );
      }
    }

    return completer.future;
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
      context.showMessage(
        "Please enter a valid amount",
        type: MessageType.error,
      );
      return;
    }

    // Show loading overlay
    if (!mounted) return;
    context.showLoading();

    try {
      if (widget.taskId == null || widget.taskId!.isEmpty) return;
      final task = await ref.read(taskDetailProvider(widget.taskId!).future);
      final providerId = task.assignment?.providerId;
      final paymentsClient = ref.read(paymentsClientProvider);

      final payload = WebhookPayload.payment(
        _amount,
        userId: widget.userId,
        taskId: widget.taskId,
      );

      final mockTransferPayload = WebhookPayload.transfer(
        task.providerPayout ?? _amount,
        userId: providerId,
        taskId: widget.taskId,
      );

      await paymentsClient.processPaymentWebhook(payload);

      if (providerId != null) {
        await paymentsClient.processPaymentWebhook(mockTransferPayload);
      }

      if (!mounted) return;
      context.hideLoading();

      final info = PaymentInfo(isSuccessful: true, amount: _amount);
      Navigator.of(context).pop(info);
    } catch (e) {
      if (!mounted) return;
      context.hideLoading();
      context.showMessage("Unable to process payment", type: MessageType.error);
    }
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.surface;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final cardColor = isDark
        ? AppColors.darkerBackground
        : AppColors.background;

    return PopScope(
      canPop: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar with Centered Drag Handle & Right Close Button
                SizedBox(
                  height: 32.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Container(
                          width: 36.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white30 : Colors.black26,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(20.r),
                            child: Container(
                              width: 30.r,
                              height: 30.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.15)
                                    : Colors.black.withValues(alpha: 0.08),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : Colors.black.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16.sp,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),

                // Title Section
                Text(
                  'Card Payment',
                  style: GoogleFonts.inter(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Transactions are securely processed.',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 14.h),

                // Amount Section
                if (widget.amount != null)
                  _buildFixedAmountBanner(
                    colorScheme,
                    isDark,
                    cardColor,
                    textColor,
                  )
                else
                  _buildAmountField(colorScheme, isDark),
                SizedBox(height: 12.h),

                // Test Card Selector
                _buildTestCardSelector(colorScheme, isDark),
                SizedBox(height: 12.h),

                // Card Form
                _buildCardForm(colorScheme, isDark),
                SizedBox(height: 16.h),

                // Pay Button
                _buildPayButton(colorScheme),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Fixed Amount Banner ──

  Widget _buildFixedAmountBanner(
    ColorScheme colorScheme,
    bool isDark,
    Color cardColor,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            // '₦${widget.amount!.toStringAsFixed(2)}',
            widget.amount?.toNaira(2) ?? '_',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Amount Field ──

  Widget _buildAmountField(ColorScheme colorScheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Amount (₦)', colorScheme),
        SizedBox(height: 6.h),
        TextFormField(
          controller: _amountCtrl,
          readOnly: widget.amount != null,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withValues(alpha: 0.25),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 12.w, right: 6.w),
              child: Text(
                '₦',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            filled: true,
            fillColor: colorScheme.onSurface.withValues(alpha: 0.04),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 10.h,
            ),
          ),
        ),
      ],
    );
  }

  // ── Card Form ──

  Widget _buildTestCardSelector(ColorScheme colorScheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Quick Fill Test Card', colorScheme),
        SizedBox(height: 6.h),
        SizedBox(
          height: 32.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _testCards.length,
            separatorBuilder: (_, _) => SizedBox(width: 8.w),
            itemBuilder: (_, i) {
              final card = _testCards[i];
              return GestureDetector(
                onTap: () => _fillCard(card),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      card.label,
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCardForm(ColorScheme colorScheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Card Details', colorScheme),
        SizedBox(height: 6.h),
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
        SizedBox(height: 10.h),
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
            SizedBox(width: 10.w),
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
      text: _amount > 0 ? 'Pay ${widget.amount?.toNaira(2)}' : 'Pay Now',
      height: 44.h,
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
        fontSize: 12.5.sp,
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
        fontSize: 13.5.sp,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 13.5.sp,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        prefixIcon: prefixIcon,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: colorScheme.onSurface.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
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
