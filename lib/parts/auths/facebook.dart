import 'package:anxeb_flutter/anxeb.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart' as FB;

class FacebookAuth extends AuthProvider {
  FB.FacebookAuth _facebook;

  FacebookAuth(Application application) : super(application) {
    _facebook = FB.FacebookAuth.instance;
  }

  @override
  Future logout() async {
    await _facebook.logOut();
  }

  @override
  Future<AuthResultModel> login({bool silent}) async {
    try {
      FB.AccessToken session;

      if (silent != false && await _facebook.accessToken != null) {
        session = await _facebook.accessToken;
      } else {
        var auth = await _facebook.login(permissions: [
          'email'
        ]);
        if (auth != null) {
          if (auth.status == FB.LoginStatus.failed) {
            throw Exception(auth.message);
          }
          if (auth.status == FB.LoginStatus.success) {
            session = auth.accessToken;
          }
        }
      }

      if (session != null) {
        var api = Api('https://graph.facebook.com/v12.0/');
        var profileData = await api.get('me?fields=name,first_name,last_name,email&access_token=${session.token}');

        AuthResultModel result = AuthResultModel();
        result.id = profileData['id'];
        result.firstNames = profileData['first_name'];
        result.lastNames = profileData['last_name'];
        result.email = profileData['email'];
        result.photo = 'https://graph.facebook.com/v12.0/me/picture?height=320&access_token=${session.token}';
        result.token = session.token;
        result.provider = 'facebook';
        result.meta = {
          'userId': session.userId,
          'expires': session.expires.toIso8601String(),
          'permissions': session.grantedPermissions,
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
