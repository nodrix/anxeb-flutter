import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:anxeb_flutter/anxeb.dart';
import 'package:dio/io.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum ApiMethods { PUT, GET, POST, DELETE }

class Api {
  String _uri;
  Dio _dio;
  String token;

  Api(String uri, {this.token, Duration connectTimeout, Duration receiveTimeout}) {
    _uri = uri;

    _dio = Dio(BaseOptions(
      baseUrl: _uri,
      connectTimeout: connectTimeout ?? const Duration(seconds: 7),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 7),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        options.headers['content-type'] = options.headers['content-type'] ?? 'application/json';
        options.headers['source'] = 'Anxeb';
        return handler.next(options);
      },
      onResponse: (Response response, ResponseInterceptorHandler handler) {
        return handler.next(response);
      },
      onError: (DioException e, ErrorInterceptorHandler handler) {
        return handler.next(e);
      },
    ));

    if (kIsWeb != true) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        return HttpClient()..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      };
    }
  }

  Interceptors get interceptors => _dio.interceptors;

  Future<Data> _process(ApiMethods method, String route, {data, query, Function(int count, int total) progress, CancelToken cancelToken, Options options}) async {
    var res = await request(method, route, data: data, query: query, progress: progress, cancelToken: cancelToken, options: options);
    return Data(res.data);
  }

  Future<Response> request(ApiMethods method, String route, {data, query, Function(int count, int total) progress, CancelToken cancelToken, Options options}) async {
    var body;
    if (data != null) {
      if (data is Data) {
        body = data.toObjects();
      } else if (data is Model) {
        body = data.toObjects();
      } else {
        body = data;
      }
    }

    if (options == null) {
      options = Options(contentType: 'application/json');
    }

    try {
      switch (method) {
        case ApiMethods.GET:
          return await _dio.get(route, queryParameters: query, cancelToken: cancelToken, options: options);
        case ApiMethods.DELETE:
          return await _dio.delete(route, queryParameters: query, cancelToken: cancelToken, data: body, options: options);
        case ApiMethods.POST:
          return await _dio.post(route, queryParameters: query, cancelToken: cancelToken, onSendProgress: progress, data: body, options: options);
        case ApiMethods.PUT:
          return await _dio.put(route, queryParameters: query, cancelToken: cancelToken, onSendProgress: progress, data: body, options: options);
      }
    } catch (err) {
      var apiException = ApiException.fromErr(err);
      if (apiException != null) {
        throw apiException;
      } else {
        throw err;
      }
    }
    return null;
  }

  String getUri(String path) => _uri + path;

  Future<Data> delete(String route, [data]) => _process(ApiMethods.DELETE, route, data: data);

  Future<Data> post(String route, data, {Function(int count, int total) progress, CancelToken cancelToken, Options options}) => _process(ApiMethods.POST, route, data: data, progress: progress, cancelToken: cancelToken, options: options);

  Future<Data> put(String route, data, {Function(int count, int total) progress, CancelToken cancelToken}) => _process(ApiMethods.PUT, route, data: data, progress: progress, cancelToken: cancelToken);

  Future<Data> get(String route, [query]) => _process(ApiMethods.GET, route, query: query);

  Future<Uint8List> download(String route, {Function(int count, int total) progress, CancelToken cancelToken, query}) async {
    try {
      Response response = await _dio.get(
        route,
        onReceiveProgress: (count, total) => progress(count, count > total ? count : total),
        cancelToken: cancelToken,
        queryParameters: query,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status < 500,
        ),
      );
      return response.data;
    } catch (err) {
      var apiException = ApiException.fromErr(err);
      if (apiException != null) {
        throw apiException;
      } else {
        throw err;
      }
    }
  }

  Future<Data> upload(String route, {Map<String, dynamic> form, Map<String, PlatformFile> files, Function(int count, int total) progress, CancelToken cancelToken, query}) async {
    try {
      for (var i = 0; i < files.entries.length; i++) {
        var element = files.entries.elementAt(i);
        var file = element.value;
        var $key = element.key ?? 'file';

        if (file != null) {
          var contentType = lookupMimeType(file.name);
          form[$key] = MultipartFile.fromBytes(file.bytes, filename: file.name, contentType: MediaType.parse(contentType));
        }
      }

      var res = await _dio.put(
        route,
        data: FormData.fromMap(form),
        onSendProgress: (count, total) => progress(count, total),
        cancelToken: cancelToken,
        queryParameters: query,
      );
      if (res != null && res.data != null) {
        return Data(res.data);
      }
    } catch (err) {
      var apiException = ApiException.fromErr(err);
      if (apiException != null) {
        throw apiException;
      } else {
        throw err;
      }
    }
    return null;
  }

  String get uri => _uri;
}

class ApiException implements Exception {
  final String message;
  final dynamic code;
  final dynamic raw;
  final ApiException inner;

  ApiException(this.message, this.code, this.raw, [this.inner]);

  factory ApiException.fromData(data) {
    return ApiException(data['message'], data['code'], data);
  }

  factory ApiException.fromErr(err) {
    if (err is DioException) {
      if (err.type == DioExceptionType.connectionTimeout) {
        return ApiException(translate('anxeb.middleware.api.exception.connect_timeout'), 0, err); //TR Error de comunicación, favor revisar su conexión a la red
      } else if (err.type == DioExceptionType.receiveTimeout) {
        return ApiException(translate('anxeb.middleware.api.exception.receive_timeout'), 408, err); //TR Tiempo de respuesta prolongado
      } else if (err.type == DioExceptionType.sendTimeout) {
        return ApiException(translate('anxeb.middleware.api.exception.send_timeout'), 408, err); //TR Tiempo de petición prolongado
      } else if (err.type == DioExceptionType.cancel) {
        return ApiException(translate('anxeb.middleware.api.exception.user_cancelled'), 408, err); //TR Conexión desestimada por usuario o administrador
      } else if (err.error is SocketException) {
        return ApiException(translate('anxeb.middleware.api.exception.socket_exception'), 0, err); //TR Error de comunicación, favor revisar su conexión al Internet
      } else {
        try {
          if (err != null && err.response != null && err.response.data != null && err.response.data['data'] != null && err.response.data['data']['status'] != null) {
            var status = err.response.data['data']['status'];
            return ApiException._getStatusException(err, status: status) ?? ApiException(err.response.data['message'] ?? translate('anxeb.middleware.api.exception.internal_error'), status, err); //TR Error interno
          } else if (err != null && err.response != null && err.response.data != null && err.response.data['message'] != null && err.response.data['code'] != null) {
            var code = err.response.data['code'];
            final inner = err.response.data['inner'] != null ? ApiException.fromData(err.response.data['inner']) : null;
            return ApiException._getStatusException(err, status: code, inner: inner) ?? ApiException(err.response.data['message'] ?? translate('anxeb.middleware.api.exception.internal_error'), code, err, inner); //TR Error interno
          } else {
            return null;
          }
        } catch (errc) {
          return ApiException._getStatusException(err, body: err.error.toString()) ?? ApiException(err.message ?? translate('anxeb.middleware.api.exception.internal_error'), 0, err);
        }
      }
    } else {
      return null;
    }
  }

  static ApiException _getStatusException(err, {dynamic status, String body, ApiException inner}) {
    var bodyStatus;

    if (body != null) {
      var codes = [400, 401, 402, 403, 404, 405, 408, 500];
      for (var ic in codes) {
        if (body.contains('[$ic]')) {
          bodyStatus = ic;
          break;
        }
      }
    }

    var statusStr = status != null ? status.toString() : bodyStatus;
    if (statusStr == null) {
      return null;
    }
    switch (statusStr) {
      case '400':
        return ApiException(translate('anxeb.middleware.api.exception.status_400'), 400, err, inner); //TR Instrucción o llamada inválida
      case '401':
        return ApiException(translate('anxeb.middleware.api.exception.status_401'), 401, err, inner); //TR Acceso al recurso denegado
      case '402':
        return ApiException(translate('anxeb.middleware.api.exception.status_402'), 402, err, inner); //TR Pago requerido
      case '403':
        return ApiException(translate('anxeb.middleware.api.exception.status_403'), 403, err, inner); //TR Acceso al recurso denegado
      case '404':
        return ApiException(translate('anxeb.middleware.api.exception.status_404'), 404, err, inner); //TR Recurso no encontrado
      case '405':
        return ApiException(translate('anxeb.middleware.api.exception.status_405'), 405, err, inner); //TR Instrucción o llamada inválida
      case '408':
        return ApiException(translate('anxeb.middleware.api.exception.status_408'), 408, err, inner); //TR Tiempo de respuesta prolongado
      case '500':
        return ApiException(translate('anxeb.middleware.api.exception.status_500'), 500, err, inner); //TR Error interno, recurso no encontrado en servidor
    }
    return null;
  }

  dynamic get meta {
    if (raw is DioException) {
      try {
        return (raw as DioException).response.data['meta'];
      } catch (err) {
        return null;
      }
    } else {
      return raw['meta'];
    }
  }

  String toString() {
    return message;
  }
}
