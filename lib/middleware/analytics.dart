import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'device.dart';
import 'scope.dart';

class Analytics {
  Scope _scope;
  String _token;
  FirebaseAnalytics _analytics;
  FirebaseMessaging _messaging;
  FirebaseAnalyticsObserver _observer;
  Function(String token) _onToken;
  Function(RemoteMessage message, MessageEventType event) _onMessage;
  Function(RemoteMessage message, MessageEventType event) _onMessageGlobal;
  List<dynamic> notifications;

  Analytics() {
    notifications = [];
  }

  Future init({Function(RemoteMessage message, MessageEventType event) onMessage}) async {
    _onMessageGlobal = onMessage;
    try {
      await Firebase.initializeApp();
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics);
      _messaging = FirebaseMessaging.instance;
      reset();
      _token = await _messaging.getToken();
      if (Device.isIOS) {
        _messaging.requestPermission();
      }
      _messaging.onTokenRefresh.listen((token) {
        _token = token;
        _onToken?.call(_token);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleMessage(message, MessageEventType.none);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessage(message, MessageEventType.resume);
      });
    } catch (err) {
      print(err);
    }
  }

  void reset() {
    _onToken = null;
    _onMessage = null;
  }

  void setup({Scope scope}) {
    _scope = scope;
    if (_scope?.key != null) {
      firebase.logEvent(name: 'view_navigation', parameters: {'name': _scope.key});
    }
  }

  Future<void> log(String name, {Map<String, dynamic> params}) {
    return firebase.logEvent(name: name, parameters: params);
  }

  Future<void> property(String name, String value) {
    return firebase.setUserProperty(name: name, value: value);
  }

  Future<void> setUserId(String id) {
    return firebase.setUserId(id: id);
  }

  Future<void> login() {
    return firebase.logEvent(name: 'login');
  }

  Future<void> logout() {
    return firebase.logEvent(name: 'logout');
  }

  Future<void> signUp() {
    return firebase.logEvent(name: 'sign_up');
  }

  void configure({Function(String token) onToken, Function(RemoteMessage message, MessageEventType event) onMessage}) {
    if (onToken != null) {
      _onToken = onToken;
    }
    if (onMessage != null) {
      _onMessage = onMessage;
    }
  }

  void _handleMessage(RemoteMessage message, MessageEventType event) {
    RemoteNotification notification = message?.notification;

    var $title;
    var $body;

    if (notification != null) {
      $title = notification.title;
      $body = notification.body;
      notifications.add(message);
    }

    if (_scope != null && _scope.mounted == true && $title != null && $body != null) {
      _scope.alerts.notification($title, message: $body).show();
    }

    _onMessageGlobal?.call(message, event);
    _onMessage?.call(message, event);
  }

  String get token => _token;

  FirebaseAnalytics get firebase => _analytics;

  FirebaseMessaging get messaging => _messaging;

  FirebaseAnalyticsObserver get observer => _observer;
}

enum MessageEventType { none, resume }
