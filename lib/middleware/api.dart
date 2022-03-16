import 'dart:async';
import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as Path;
import 'data.dart';
import 'model.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

enum ApiMethods { PUT, GET, POST, DELETE }

class Api {
  String _uri;
  Dio _dio;
  String token;

  Api(String uri, {this.token, int connectTimeout, int receiveTimeout}) {
    _uri = uri;

    _dio = Dio(BaseOptions(
      baseUrl: _uri,
      connectTimeout: connectTimeout ?? 7000,
      receiveTimeout: receiveTimeout ?? 7000,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        options.headers['content-type'] = options.headers['content-type'] ?? 'application/json';
        return handler.next(options);
      },
      onResponse: (Response response, ResponseInterceptorHandler handler) {
        return handler.next(response);
      },
      onError: (DioError e, ErrorInterceptorHandler handler) {
        return handler.next(e);
      },
    ));

    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        //TODO: Validate PEM Certificate
        return true;
      };
      return client;
    };
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
          return await _dio.get(route, queryParameters: query, cancelToken: cancelToken);
        case ApiMethods.DELETE:
          return await _dio.delete(route, queryParameters: query, cancelToken: cancelToken, data: body);
        case ApiMethods.POST:
          return await _dio.post(route, queryParameters: query, cancelToken: cancelToken, onSendProgress: progress, data: body, options: options);
        case ApiMethods.PUT:
          return await _dio.put(route, queryParameters: query, cancelToken: cancelToken, onSendProgress: progress, data: body);
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

  Future<File> download(String route, {String location, Function(int count, int total) progress, CancelToken cancelToken, query}) async {
    try {
      Response response = await _dio.get(
        route,
        onReceiveProgress: (count, total) => progress(count, total),
        cancelToken: cancelToken,
        queryParameters: query,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status < 500,
        ),
      );

      File file = File(location);
      var raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      await raf.close();
      return file;
    } catch (err) {
      var apiException = ApiException.fromErr(err);
      if (apiException != null) {
        throw apiException;
      } else {
        throw err;
      }
    }
  }

  Future<Data> upload(String route, {form, Map<String, File> files, Function(int count, int total) progress, CancelToken cancelToken, query}) async {
    try {
      for (var i = 0; i < files.entries.length; i++) {
        var element = files.entries.elementAt(i);
        var file = element.value;
        var $key = element.key ?? 'file';

        if (file != null) {
          var contentType = lookupMimeType(file.path);
          form[$key] = await MultipartFile.fromFile(file.path, filename: Path.basename(file.path), contentType: MediaType.parse(contentType));
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

  ApiException(this.message, this.code, this.raw);

  factory ApiException.fromErr(err) {
    if (err is DioError) {
      if (err.type == DioErrorType.connectTimeout) {
        return ApiException('Error de comunicación, favor revisar su conexión a la red', 0, err);
      } else if (err.type == DioErrorType.receiveTimeout) {
        return ApiException('Tiempo de respuesta prolongado', 408, err);
      } else if (err.type == DioErrorType.sendTimeout) {
        return ApiException('Tiempo de petición prolongado', 408, err);
      } else if (err.type == DioErrorType.cancel) {
        return ApiException('Conexión desestimada por usuario o administrador', 408, err);
      } else if (err.error is SocketException) {
        return ApiException('Error de comunicación, favor revisar su conexión al Internet', 0, err);
      } else {
        try {
          if (err != null && err.response != null && err.response.data != null && err.response.data['data'] != null && err.response.data['data']['status'] != null) {
            var status = err.response.data['data']['status'];
            return ApiException._getStatusException(err, status: status) ?? ApiException(err.response.data['message'] ?? 'Error interno', status, err);
          } else if (err != null && err.response != null && err.response.data != null && err.response.data['message'] != null && err.response.data['code'] != null) {
            var code = err.response.data['code'];
            return ApiException._getStatusException(err, status: code) ?? ApiException(err.response.data['message'] ?? 'Error interno', code, err);
          } else {
            return null;
          }
        } catch (errc) {
          return ApiException._getStatusException(err, body: err.error.toString()) ?? ApiException(err.message ?? 'Error interno', 0, err);
        }
      }
    } else {
      return null;
    }
  }

  static ApiException _getStatusException(err, {dynamic status, String body}) {
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
        return ApiException('Instrucción o llamada inválida', 400, err);
      case '401':
        return ApiException('Acceso al recurso denegado', 401, err);
      case '402':
        return ApiException('Pago requerido', 402, err);
      case '403':
        return ApiException('Acceso al recurso denegado', 403, err);
      case '404':
        return ApiException('Recurso no encontrado', 404, err);
      case '405':
        return ApiException('Instrucción o llamada inválida', 405, err);
      case '408':
        return ApiException('Tiempo de respuesta prolongado', 408, err);
      case '500':
        return ApiException('Error interno, recurso no encontrado en servidor', 500, err);
    }
    return null;
  }

  String toString() {
    return message;
  }
}
