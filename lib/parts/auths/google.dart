import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/middleware/auth.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuth extends ScopeAuth {
  GoogleSignIn _google;

  GoogleAuth(Scope scope) : super(scope) {
    _google = GoogleSignIn(
      signInOption: scope.application.settings.auths.google.signInOption ?? SignInOption.standard,
      scopes: scope.application.settings.auths.google.scopes ?? [],
      hostedDomain: scope.application.settings.auths.google.hostedDomain,
      clientId: scope.application.settings.auths.google.clientId,
    );
  }

  @override
  Future<bool> logout() async {
    try {
      await _google.signOut();
      return true;
    } catch (err) {
      scope.alerts.exception(err, title: 'Error Autenticador de Google');
    }
    return false;
  }

  @override
  Future<AuthResultModel> login({bool silent}) async {
    try {
      GoogleSignInAccount profileData;

      if (silent != false && (_google.currentUser != null || await _google.isSignedIn())) {
        profileData = _google.currentUser ?? await _google.signInSilently();
      } else {
        profileData = await _google.signIn();
      }

      if (profileData != null) {
        var authData = await profileData.authentication;
        var displayNameParts = profileData.displayName.split(' ');

        AuthResultModel result = AuthResultModel();
        result.id = profileData.id;
        result.firstNames = displayNameParts[0];
        result.lastNames = displayNameParts.length > 1 ? displayNameParts[1] : null;
        result.email = profileData.email;
        result.token = authData.idToken;
        result.provider = 'google';
        result.meta = {
          'photoUrl': profileData.photoUrl,
          'serverAuthCode': authData.serverAuthCode,
          'accessToken': authData.accessToken,
        };
        return result;
      }
    } catch (err) {
      scope.alerts.exception(err, title: 'Error Autenticador de Google');
    }
    return null;
  }
}
