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
