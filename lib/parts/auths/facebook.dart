import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/middleware/auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class FacebookAuth extends AuthProvider {
  FacebookLogin _facebook;

  FacebookAuth(Application application) : super(application) {
    _facebook = FacebookLogin();
  }

  @override
  Future logout() async {
    await _facebook.logOut();
  }

  @override
  Future<AuthResultModel> login({bool silent}) async {
    try {
      FacebookAccessToken session;

      if (silent != false && await _facebook.isLoggedIn) {
        session = await _facebook.currentAccessToken;
      } else {
        var auth = await _facebook.logIn(['email']);
        if (auth != null) {
          if (auth.status == FacebookLoginStatus.error) {
            throw Exception(auth.errorMessage);
          }
          if (auth.status == FacebookLoginStatus.loggedIn) {
            session = auth.accessToken;
          }
        }
      }

      if (session != null) {
        var api = Api('https://graph.facebook.com/v7.0/');
        var profileData = await api.get('me?fields=name,first_name,last_name,email&access_token=${session.token}');

        AuthResultModel result = AuthResultModel();
        result.id = profileData['id'];
        result.firstNames = profileData['first_name'];
        result.lastNames = profileData['last_name'];
        result.email = profileData['email'];
        result.photo = 'https://graph.facebook.com/v7.0/me/picture?height=320&access_token=${session.token}';
        result.token = session.token;
        result.provider = 'facebook';
        result.meta = {
          'userId': session.userId,
          'expires': session.expires.toIso8601String(),
          'permissions': session.permissions,
          'declinedPermissions': session.declinedPermissions,
        };
        return result;
      }
    } catch (err) {
      throw err;
    }
    return null;
  }
}
