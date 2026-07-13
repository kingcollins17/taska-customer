import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'enviroment.freezed.dart';
part 'enviroment.g.dart';

enum AppEnvironment { local, staging, production }

@freezed
abstract class Environment with _$Environment {
  const factory Environment({
    required String baseUrl,
    required String baseDomain,
    @Default(AppEnvironment.local) AppEnvironment appEnv,
  }) = _Environment;

  factory Environment.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentFromJson(json);

  factory Environment.fromEnv() {
    final envString = dotenv.env['APP_ENV']?.toLowerCase() ?? 'local';
    final appEnv = AppEnvironment.values.firstWhere(
      (e) => e.name == envString,
      orElse: () => AppEnvironment.local,
    );

    return Environment(
      baseUrl: dotenv.env['BASE_URL'] ?? '',
      baseDomain: dotenv.env['BASE_DOMAIN'] ?? '',
      appEnv: appEnv,
    );
  }
}
