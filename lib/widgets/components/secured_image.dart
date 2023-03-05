import 'dart:async';
import 'package:http/http.dart';
import 'dart:ui' as ui show instantiateImageCodec, Codec;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class SecuredImage extends ImageProvider<SecuredImage> {
  final Client _client = new Client();
  final String url;
  final double scale;
  final Map<String, String> headers;

  SecuredImage(
    this.url, {
    this.scale = 1.0,
    this.headers,
  });

  @override
  Future<SecuredImage> obtainKey(ImageConfiguration configuration) {
    return new SynchronousFuture<SecuredImage>(this);
  }

  @override
  ImageStreamCompleter load(SecuredImage key, decode) {
    return new MultiFrameImageStreamCompleter(
        codec: _loadAsync(key, decode),
        scale: key.scale,
        informationCollector: () sync* {
          yield DiagnosticsProperty<ImageProvider>('Image provider', this);
          yield DiagnosticsProperty<ImageProvider>('Image key', key, defaultValue: null);
        });
  }

  Future<ui.Codec> _loadAsync(SecuredImage key, decode) async {
    assert(key == this);
    final Uri resolved = Uri.base.resolve(key.url);
    final Response response = await _client.get(resolved, headers: headers);

    if (response.statusCode != 200) throw Exception('HTTP request failed, statusCode: ${response?.statusCode}, $resolved');
    if (response.bodyBytes.lengthInBytes == 0) throw new Exception('Content is empty: $resolved');

    return await ui.instantiateImageCodec(response.bodyBytes);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final SecuredImage typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);
}
