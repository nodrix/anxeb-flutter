import 'package:anxeb_flutter/anxeb.dart';

class GoogleAuth extends AuthProvider {
  GoogleSignIn _google;

  GoogleAuth(Application application) : super(application) {
    _google = GoogleSignIn(
      signInOption: application.settings.auths.google.signInOption ?? SignInOption.standard,
      scopes: application.settings.auths.google.scopes ?? [],
      hostedDomain: application.settings.auths.google.hostedDomain,
      clientId: application.settings.auths.google.clientId,
    );
  }

  @override
  Future logout() async {
    await _google.signOut();
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
        var pind = profileData.photoUrl.lastIndexOf('=');
        var photo = pind > 0 ? profileData.photoUrl.substring(0, pind) : profileData.photoUrl;

        AuthResultModel result = AuthResultModel();
        result.id = profileData.id;
        result.firstNames = displayNameParts[0];
        result.lastNames = displayNameParts.length > 1 ? displayNameParts[1] : null;
        result.email = profileData.email;
        result.photo = photo;
        result.token = authData.idToken;
        result.provider = 'google';
        result.meta = {
          'serverAuthCode': profileData.serverAuthCode,
          'accessToken': authData.accessToken,
        };
        return result;
      }
    } catch (err) {
      throw err;
    }
    return null;
  }
}
