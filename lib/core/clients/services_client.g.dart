// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'services_client.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main,avoid_redundant_argument_values

class _ServicesClient implements ServicesClient {
  _ServicesClient(this._dio, {this.baseUrl, this.errorLogger}) {
    baseUrl ??= '/api/v1';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<GenericResponse<PaginatedResponse<Service>>> getServices({
    int? page = 1,
    int? perPage = 20,
    String? search,
    String? categoryId,
    bool? isActive,
    String? sortBy = 'created_at',
    bool? sortDesc = true,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'page': page,
      r'per_page': perPage,
      r'search': search,
      r'category_id': categoryId,
      r'is_active': isActive,
      r'sort_by': sortBy,
      r'sort_desc': sortDesc,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<GenericResponse<PaginatedResponse<Service>>>(
          Options(method: 'GET', headers: _headers, extra: _extra)
              .compose(
                _dio.options,
                '/services',
                queryParameters: queryParameters,
                data: _data,
              )
              .copyWith(
                baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
              ),
        );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late GenericResponse<PaginatedResponse<Service>> _value;
    try {
      _value = GenericResponse<PaginatedResponse<Service>>.fromJson(
        _result.data!,
        (json) => PaginatedResponse<Service>.fromJson(
          json as Map<String, dynamic>,
          (json) => Service.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<GenericResponse<Service>> getService(String serviceId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<GenericResponse<Service>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/services/${serviceId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late GenericResponse<Service> _value;
    try {
      _value = GenericResponse<Service>.fromJson(
        _result.data!,
        (json) => Service.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<GenericResponse<PaginatedResponse<Service>>>
  getAvailableServicesInRegion(
    String regionId, {
    int? page = 1,
    int? perPage = 20,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'page': page,
      r'per_page': perPage,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<GenericResponse<PaginatedResponse<Service>>>(
          Options(method: 'GET', headers: _headers, extra: _extra)
              .compose(
                _dio.options,
                '/services/available/regions/${regionId}',
                queryParameters: queryParameters,
                data: _data,
              )
              .copyWith(
                baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
              ),
        );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late GenericResponse<PaginatedResponse<Service>> _value;
    try {
      _value = GenericResponse<PaginatedResponse<Service>>.fromJson(
        _result.data!,
        (json) => PaginatedResponse<Service>.fromJson(
          json as Map<String, dynamic>,
          (json) => Service.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<GenericResponse<ServiceAvailability>> checkServiceAvailabilityInRegion(
    String serviceId,
    String regionId,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<GenericResponse<ServiceAvailability>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/services/${serviceId}/available/regions/${regionId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late GenericResponse<ServiceAvailability> _value;
    try {
      _value = GenericResponse<ServiceAvailability>.fromJson(
        _result.data!,
        (json) => ServiceAvailability.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<GenericResponse<PaginatedResponse<ServiceCategory>>> getCategories({
    int? page = 1,
    int? perPage = 20,
    String? search,
    bool? isActive,
    String? sortBy = 'created_at',
    bool? sortDesc = true,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'page': page,
      r'per_page': perPage,
      r'search': search,
      r'is_active': isActive,
      r'sort_by': sortBy,
      r'sort_desc': sortDesc,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<GenericResponse<PaginatedResponse<ServiceCategory>>>(
          Options(method: 'GET', headers: _headers, extra: _extra)
              .compose(
                _dio.options,
                '/categories',
                queryParameters: queryParameters,
                data: _data,
              )
              .copyWith(
                baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl),
              ),
        );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late GenericResponse<PaginatedResponse<ServiceCategory>> _value;
    try {
      _value = GenericResponse<PaginatedResponse<ServiceCategory>>.fromJson(
        _result.data!,
        (json) => PaginatedResponse<ServiceCategory>.fromJson(
          json as Map<String, dynamic>,
          (json) => ServiceCategory.fromJson(json as Map<String, dynamic>),
        ),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<GenericResponse<ServiceCategory>> getCategory(
    String categoryId,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<GenericResponse<ServiceCategory>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/categories/${categoryId}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late GenericResponse<ServiceCategory> _value;
    try {
      _value = GenericResponse<ServiceCategory>.fromJson(
        _result.data!,
        (json) => ServiceCategory.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<GenericResponse<List<Service>>> getTopServices({
    int? limit = 10,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'limit': limit};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<GenericResponse<List<Service>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/services/top',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late GenericResponse<List<Service>> _value;
    try {
      _value = GenericResponse<List<Service>>.fromJson(
        _result.data!,
        (json) => json is List<dynamic>
            ? json
                  .map<Service>(
                    (i) => Service.fromJson(i as Map<String, dynamic>),
                  )
                  .toList()
            : List.empty(),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<GenericResponse<List<ServiceCategory>>> getTopCategories({
    int? limit = 10,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'limit': limit};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<GenericResponse<List<ServiceCategory>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/services/categories/top',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late GenericResponse<List<ServiceCategory>> _value;
    try {
      _value = GenericResponse<List<ServiceCategory>>.fromJson(
        _result.data!,
        (json) => json is List<dynamic>
            ? json
                  .map<ServiceCategory>(
                    (i) => ServiceCategory.fromJson(i as Map<String, dynamic>),
                  )
                  .toList()
            : List.empty(),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// dart format on
