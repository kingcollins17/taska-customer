// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayoutAccountPayload _$PayoutAccountPayloadFromJson(
  Map<String, dynamic> json,
) => PayoutAccountPayload(
  bankCode: json['bank_code'] as String?,
  bankName: json['bank_name'] as String?,
  accountName: json['account_name'] as String?,
  accountNumber: json['account_number'] as String?,
);

Map<String, dynamic> _$PayoutAccountPayloadToJson(
  PayoutAccountPayload instance,
) => <String, dynamic>{
  'bank_code': instance.bankCode,
  'bank_name': instance.bankName,
  'account_name': instance.accountName,
  'account_number': instance.accountNumber,
};

BankAccountVerification _$BankAccountVerificationFromJson(
  Map<String, dynamic> json,
) => BankAccountVerification(
  accountNumber: json['account_number'] as String?,
  accountName: json['account_name'] as String?,
  bankName: json['bank_name'] as String?,
  bankCode: json['bank_code'] as String?,
);

Map<String, dynamic> _$BankAccountVerificationToJson(
  BankAccountVerification instance,
) => <String, dynamic>{
  'account_number': instance.accountNumber,
  'account_name': instance.accountName,
  'bank_name': instance.bankName,
  'bank_code': instance.bankCode,
};

SupportedBank _$SupportedBankFromJson(Map<String, dynamic> json) =>
    SupportedBank(
      id: json['id'] as String?,
      bankCode: json['bank_code'] as String?,
      name: json['name'] as String?,
      logoUrl: json['logo_url'] as String?,
    );

Map<String, dynamic> _$SupportedBankToJson(SupportedBank instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bank_code': instance.bankCode,
      'name': instance.name,
      'logo_url': instance.logoUrl,
    };
