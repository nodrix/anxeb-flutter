import 'package:anxeb_flutter/anxeb.dart';
import 'package:anxeb_flutter/middleware/auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuth extends AuthProvider {
  String _fetchCallbackRoute;
  String Function() _nonce;

  AppleAuth(Application application) : super(application) {
    _fetchCallbackRoute = application.settings.auths.apple.fetchCallbackRoute;
    _nonce = application.settings.auths.apple.nonce;
  }

  @override
  Future logout() async {}

  @override
  Future<AuthResultModel> login({bool silent}) async {
    try {
      final session = await SignInWithApple.getAppleIDCredential(
        nonce: _nonce?.call(),
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (session != null) {
        var res = await application.api.post(_fetchCallbackRoute, {
          'identifier': session.userIdentifier,
          'first_name': session.givenName,
          'last_name': session.familyName,
          'email': session.email,
          'token': session.identityToken,
          'code': session.authorizationCode,
        });

        AuthResultModel result = AuthResultModel();
        result.id = session.userIdentifier;
        result.firstNames = session.givenName ?? res['first_name'];
        result.lastNames = session.familyName ?? res['last_name'];
        result.email = session.email ?? res['email'];
        result.photo = null;
        result.token = session.identityToken;
        result.provider = 'apple';
        result.meta = {
          'state': session.state,
          'authorizationCode': session.authorizationCode,
        };

        return result;
      }
    } on SignInWithAppleAuthorizationException catch (err) {
      if (err.code == AuthorizationErrorCode.canceled || err.code == AuthorizationErrorCode.unknown) {
        return null;
      }
      throw err;
    } catch (err) {
      throw err;
    }
    return null;
  }
}
