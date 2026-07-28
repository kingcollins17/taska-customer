import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seeker_app/core/designs/widgets/widgets.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/user_provider.dart';

class SelectBank extends ConsumerStatefulWidget {
  const SelectBank({super.key});

  static Future<SupportedBank?> select(BuildContext context) {
    return Navigator.push<SupportedBank>(
      context,
      MaterialPageRoute(builder: (context) => const SelectBank()),
    );
  }

  @override
  ConsumerState<SelectBank> createState() => _SelectBankState();
}

class _SelectBankState extends ConsumerState<SelectBank> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SupportedBank? _selectedBank;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banksAsync = ref.watch(supportedBanksProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Text(
          'Select Bank',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: banksAsync.when(
        data: (banks) {
          final filteredBanks = banks.where((b) {
            final name = (b.name ?? '').toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: CustomTextField(
                  controller: _searchController,
                  hintText: 'Search bank name',
                  leadingIcon: Icons.search,
                  onTap: () {}, // Handled by text field natively since it is editable
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: filteredBanks.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final bank = filteredBanks[index];
                    final isSelected = _selectedBank?.id == bank.id;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedBank = bank;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary.withValues(alpha: 0.1)
                              : colorScheme.surface,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: bank.logoUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        bank.logoUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.account_balance,
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.account_balance,
                                      color: colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Text(
                                bank.name ?? 'Unknown Bank',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: PrimaryButton(
                  text: 'Continue',
                  onPressed: _selectedBank != null
                      ? () {
                          Navigator.pop(context, _selectedBank);
                        }
                      : null,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text(err.toString())),
      ),
    );
  }
}
