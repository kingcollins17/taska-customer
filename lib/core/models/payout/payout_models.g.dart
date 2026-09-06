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

PayoutTask _$PayoutTaskFromJson(Map<String, dynamic> json) => PayoutTask(
  id: json['id'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  categoryId: json['category_id'] as String?,
  serviceId: json['service_id'] as String?,
  customerTotalPrice: json['customer_total_price'] as num?,
  platformFee: json['platform_fee'] as num?,
  providerPayout: json['provider_payout'] as num?,
  status: json['status'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$PayoutTaskToJson(PayoutTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category_id': instance.categoryId,
      'service_id': instance.serviceId,
      'customer_total_price': instance.customerTotalPrice,
      'platform_fee': instance.platformFee,
      'provider_payout': instance.providerPayout,
      'status': instance.status,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

Payout _$PayoutFromJson(Map<String, dynamic> json) => Payout(
  id: json['id'] as String?,
  providerId: json['provider_id'] as String?,
  customerId: json['customer_id'] as String?,
  taskId: json['task_id'] as String?,
  payoutAmount: json['payout_amount'] as num?,
  customerPaymentAmount: json['customer_payment_amount'] as num?,
  status: json['status'] as String?,
  description: json['description'] as String?,
  paymentUrl: json['payment_url'] as String?,
  urlGeneratedAt: json['url_generated_at'] as String?,
  reference: json['reference'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  task: json['task'] == null
      ? null
      : PayoutTask.fromJson(json['task'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PayoutToJson(Payout instance) => <String, dynamic>{
  'id': instance.id,
  'provider_id': instance.providerId,
  'customer_id': instance.customerId,
  'task_id': instance.taskId,
  'payout_amount': instance.payoutAmount,
  'customer_payment_amount': instance.customerPaymentAmount,
  'status': instance.status,
  'description': instance.description,
  'payment_url': instance.paymentUrl,
  'url_generated_at': instance.urlGeneratedAt,
  'reference': instance.reference,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'task': instance.task,
};
