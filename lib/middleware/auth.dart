import 'package:anxeb_flutter/parts/auths/facebook.dart';
import 'package:anxeb_flutter/parts/auths/google.dart';
import 'package:anxeb_flutter/parts/auths/twitter.dart';
import 'model.dart';
import 'scope.dart';

class ScopeAuth {
  final Scope scope;

  ScopeAuth(this.scope);

  Future<bool> logout() async => false;

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
    field(() => photoUrl, (v) => photoUrl = v, 'photoUrl');
    field(() => token, (v) => token = v, 'token');
    field(() => provider, (v) => provider = v, 'provider');
    field(() => meta, (v) => meta = v, 'meta');
  }

  String id;
  String firstNames;
  String lastNames;
  String email;
  String photoUrl;
  String token;
  String provider;
  dynamic meta;
}

class ScopeAuths {
  GoogleAuth _google;
  TwitterAuth _twitter;
  FacebookAuth _facebook;

  ScopeAuths(Scope scope) {
    _google = GoogleAuth(scope);
    _twitter = TwitterAuth(scope);
    _facebook = FacebookAuth(scope);
  }

  GoogleAuth get google => _google;

  TwitterAuth get twitter => _twitter;

  FacebookAuth get facebook => _facebook;
}
