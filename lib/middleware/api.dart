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

  Api(String uri, {this.token}) {
    _uri = uri;

    _dio = Dio(BaseOptions(
      baseUrl: _uri,
      connectTimeout: 7000,
      receiveTimeout: 7000,
    ));

    _dio.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options) {
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      options.headers['origin-service-key'] = 'control';
      options.headers['content-type'] = 'application/json';

      return options;
    }, onResponse: (Response response) {
      return response;
    }, onError: (DioError e) {
      return e;
    }));

    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        //TODO: Validate PEM Certificate
        return true;
      };
    };
  }

  Interceptors get interceptors => _dio.interceptors;

  Future<Data> _process(ApiMethods method, String route, {data}) async {
    var res = await request(method, route, data: data);
    return Data(res.data);
  }

  Future<Response> request(ApiMethods method, String route, {data}) {
    var promise = new Completer<Response>();
    var body;

    var $method;
    switch (method) {
      case ApiMethods.GET:
        $method = _dio.get;
        break;
      case ApiMethods.DELETE:
        $method = _dio.delete;
        break;
      case ApiMethods.POST:
        $method = _dio.post;
        break;
      case ApiMethods.PUT:
        $method = _dio.put;
        break;
    }

    if (data != null) {
      if (data is Data) {
        body = data.toObjects();
      } else if (data is Model) {
        body = data.toObjects();
      } else {
        body = data;
      }
    }

    Future<Response> call = $method == _dio.get ? $method(route) : $method(route, data: body);

    call.then((res) {
      promise.complete(res);
    }).catchError((err) {
      var apiException = ApiException.fromErr(err);
      if (apiException != null) {
        promise.completeError(apiException);
      } else {
        promise.completeError(err);
      }
    });
    return promise.future;
  }

  String getUri(String path) => _uri + path;

  Future<Data> delete(String route) => _process(ApiMethods.DELETE, route);

  Future<Data> post(String route, data) => _process(ApiMethods.POST, route, data: data);

  Future<Data> put(String route, data) => _process(ApiMethods.PUT, route, data: data);

  Future<Data> get(String route) => _process(ApiMethods.GET, route);

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

  Future<Data> upload(String route, {form, File file, String fieldName, Function(int count, int total) progress, CancelToken cancelToken, query}) async {
    var contentType = lookupMimeType(file.path);
    
    try {
      form[fieldName ?? 'file'] = await MultipartFile.fromFile(file.path, filename: Path.basename(file.path), contentType: MediaType.parse(contentType));
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
  final int code;

  ApiException(this.message, this.code);

  factory ApiException.fromErr(err) {
    if (err is DioError) {
      if (err.type == DioErrorType.CONNECT_TIMEOUT) {
        return ApiException('Error de comunicación, favor revisar su conexión a la red', 0);
      } else if (err.type == DioErrorType.RECEIVE_TIMEOUT) {
        return ApiException('Tiempo de respuesta prolongado', 408);
      } else if (err.type == DioErrorType.SEND_TIMEOUT) {
        return ApiException('Tiempo de petición prolongado', 408);
      } else if (err.type == DioErrorType.CANCEL) {
        return ApiException('Conexión desestimada por usuario o administrador', 408);
      } else if (err.error is SocketException) {
        return ApiException('Error de comunicación, favor revisar su conexión al Internet', 0);
      } else {
        if (err != null && err.response != null && err.response.data != null && err.response.data['message'] != null && err.response.data['code'] != null) {
          return ApiException(err.response.data['message'], err.response.data['code']);
        } else {
          return null;
        }
      }
    } else {
      return null;
    }
  }

  String toString() {
    return message;
  }
}
