import 'package:json_annotation/json_annotation.dart';

part 'payout_models.g.dart';

@JsonSerializable()
class PayoutAccountPayload {
  @JsonKey(name: 'bank_code')
  final String? bankCode;
  @JsonKey(name: 'bank_name')
  final String? bankName;
  @JsonKey(name: 'account_name')
  final String? accountName;
  @JsonKey(name: 'account_number')
  final String? accountNumber;

  PayoutAccountPayload({
    this.bankCode,
    this.bankName,
    this.accountName,
    this.accountNumber,
  });

  factory PayoutAccountPayload.fromJson(Map<String, dynamic> json) =>
      _$PayoutAccountPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$PayoutAccountPayloadToJson(this);
}

@JsonSerializable()
class BankAccountVerification {
  @JsonKey(name: 'account_number')
  final String? accountNumber;
  @JsonKey(name: 'account_name')
  final String? accountName;
  @JsonKey(name: 'bank_name')
  final String? bankName;
  @JsonKey(name: 'bank_code')
  final String? bankCode;

  BankAccountVerification({
    this.accountNumber,
    this.accountName,
    this.bankName,
    this.bankCode,
  });

  factory BankAccountVerification.fromJson(Map<String, dynamic> json) =>
      _$BankAccountVerificationFromJson(json);

  Map<String, dynamic> toJson() => _$BankAccountVerificationToJson(this);
}

@JsonSerializable()
class SupportedBank {
  final String? id;
  @JsonKey(name: 'bank_code')
  final String? bankCode;
  final String? name;
  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  SupportedBank({
    this.id,
    this.bankCode,
    this.name,
    this.logoUrl,
  });

  factory SupportedBank.fromJson(Map<String, dynamic> json) =>
      _$SupportedBankFromJson(json);

  Map<String, dynamic> toJson() => _$SupportedBankToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PayoutTask {
  final String? id;
  final String? title;
  final String? description;
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @JsonKey(name: 'service_id')
  final String? serviceId;
  @JsonKey(name: 'customer_total_price')
  final num? customerTotalPrice;
  @JsonKey(name: 'platform_fee')
  final num? platformFee;
  @JsonKey(name: 'provider_payout')
  final num? providerPayout;
  final String? status;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  PayoutTask({
    this.id,
    this.title,
    this.description,
    this.categoryId,
    this.serviceId,
    this.customerTotalPrice,
    this.platformFee,
    this.providerPayout,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory PayoutTask.fromJson(Map<String, dynamic> json) =>
      _$PayoutTaskFromJson(json);

  Map<String, dynamic> toJson() => _$PayoutTaskToJson(this);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class Payout {
  final String? id;
  @JsonKey(name: 'provider_id')
  final String? providerId;
  @JsonKey(name: 'customer_id')
  final String? customerId;
  @JsonKey(name: 'task_id')
  final String? taskId;
  @JsonKey(name: 'payout_amount')
  final num? payoutAmount;
  @JsonKey(name: 'customer_payment_amount')
  final num? customerPaymentAmount;
  final String? status;
  final String? description;
  @JsonKey(name: 'payment_url')
  final String? paymentUrl;
  @JsonKey(name: 'url_generated_at')
  final String? urlGeneratedAt;
  final String? reference;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  final PayoutTask? task;

  Payout({
    this.id,
    this.providerId,
    this.customerId,
    this.taskId,
    this.payoutAmount,
    this.customerPaymentAmount,
    this.status,
    this.description,
    this.paymentUrl,
    this.urlGeneratedAt,
    this.reference,
    this.createdAt,
    this.updatedAt,
    this.task,
  });

  factory Payout.fromJson(Map<String, dynamic> json) => _$PayoutFromJson(json);

  Map<String, dynamic> toJson() => _$PayoutToJson(this);
}

