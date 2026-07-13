import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'access_token')
  final String? accessToken;
  final String? detail;
  @JsonKey(name: 'token_type')
  final String? tokenType;

  LoginResponse({this.accessToken, this.tokenType, this.detail});

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}
