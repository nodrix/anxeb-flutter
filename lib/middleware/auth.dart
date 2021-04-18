import 'package:anxeb_flutter/parts/auths/apple.dart';
import 'package:anxeb_flutter/parts/auths/facebook.dart';
import 'package:anxeb_flutter/parts/auths/google.dart';
import 'application.dart';
import 'model.dart';
import 'utils.dart';

class AuthProvider {
  final Application application;

  AuthProvider(this.application);

  Future logout() async => {};

  Future<AuthResultModel> login() async => null;
}

class AuthResultModel extends Model<AuthResultModel> {
  AuthResultModel([data]) : super(data);

  @override
  void init() {
    field(() => id, (v) => id = v, 'id');
    field(() => firstNames, (v) => firstNames = v, 'first_names');
    field(() => lastNames, (v) => lastNames = v, 'last_names');
    field(() => email, (v) => email = v, 'email');
    field(() => photo, (v) => photo = v, 'photo');
    field(() => token, (v) => token = v, 'token');
    field(() => provider, (v) => provider = v, 'provider');
    field(() => meta, (v) => meta = v, 'meta');
  }

  String id;
  String firstNames;
  String lastNames;
  String email;
  String photo;
  String token;
  String provider;
  dynamic meta;

  @override
  String toString() => Utils.convert.fromNamesToFullName(firstNames, lastNames);
}

class AuthProviders {
  GoogleAuth _google;
  FacebookAuth _facebook;
  AppleAuth _apple;

  AuthProviders(Application application) {
    _google = GoogleAuth(application);
    _facebook = FacebookAuth(application);
    _apple = AppleAuth(application);
  }

  GoogleAuth get google => _google;

  FacebookAuth get facebook => _facebook;

  AppleAuth get apple => _apple;
}
