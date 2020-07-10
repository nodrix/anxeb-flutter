import 'dart:convert';
import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/middleware/auth.dart';
import 'package:flutter_twitter/flutter_twitter.dart';
import 'package:oauth1/oauth1.dart';

class TwitterAuth extends AuthProvider {
  TwitterLogin _twitterLogin;

  TwitterAuth(Application application) : super(application) {
    _twitterLogin = TwitterLogin(
      consumerKey: application.settings.auths.twitter.apiKey,
      consumerSecret: application.settings.auths.twitter.apiSecret,
    );
  }

  @override
  Future logout() async {
    await _twitterLogin.logOut();
  }

  @override
  Future<AuthResultModel> login({bool silent}) async {
    try {
      TwitterSession session;

      if (silent != false && await _twitterLogin.isSessionActive) {
        session = await _twitterLogin.currentSession;
      } else {
        var auth = await _twitterLogin.authorize();
        if (auth != null) {
          if (auth.status == TwitterLoginStatus.error) {
            throw Exception(auth.errorMessage);
          }
          if (auth.status == TwitterLoginStatus.loggedIn) {
            session = auth.session;
          }
        }
      }

      if (session != null) {
        var clientCredentials = ClientCredentials(application.settings.auths.twitter.apiKey, application.settings.auths.twitter.apiSecret);
        var client = Client(SignatureMethods.hmacSha1, clientCredentials, Credentials(session.token, session.secret));
        var res = await client.get('https://api.twitter.com/1.1/account/verify_credentials.json?include_email=true&skip_status=false&include_entities=false');
        var profileData = json.decode(res.body);
        var displayNameParts = profileData['name'].split(' ');

        AuthResultModel result = AuthResultModel();
        result.id = session.userId;
        result.firstNames = displayNameParts[0];
        result.lastNames = displayNameParts.length > 1 ? displayNameParts[1] : null;
        result.email = profileData['email'] ?? (profileData['screen_name'] + '@twitter.com');
        result.photo = profileData['profile_image_url_https']?.toString()?.replaceAll('_normal.jpg', '.jpg');
        result.token = session.token;
        result.provider = 'twitter';
        result.meta = {
          'secret': session.secret,
          'username': session.username,
        };
        return result;
      }
    } catch (err) {
      throw err;
    }
    return null;
  }
}
