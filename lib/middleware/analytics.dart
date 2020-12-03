import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'scope.dart';

class Analytics {
  Scope _scope;
  String _token;
  FirebaseAnalytics _analytics;
  FirebaseMessaging _messaging;
  FirebaseAnalyticsObserver _observer;
  Function(String token) _onToken;
  Function(Map<String, dynamic> message, MessageEventType event) _onMessage;

  Analytics() {
    _analytics = FirebaseAnalytics();
    _messaging = FirebaseMessaging();
    _observer = FirebaseAnalyticsObserver(analytics: _analytics);
  }

  Future init() async {
    try {
      await Firebase.initializeApp();

      _token = await _messaging.getToken();
      if (Platform.isIOS) {
        _messaging.requestNotificationPermissions();
      }
      _messaging.onTokenRefresh.listen((token) {
        _token = token;
        _onToken?.call(_token);
      });
      _messaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          _handleMessage(message, MessageEventType.none);
        },
        onResume: (Map<String, dynamic> message) async {
          _handleMessage(message, MessageEventType.resume);
        },
        onLaunch: (Map<String, dynamic> message) async {
          _handleMessage(message, MessageEventType.launch);
        },
      );
    } catch (err) {
      print(err);
    }
  }

  void reset() {
    _scope = null;
    _onToken = null;
    _onMessage = null;
  }

  void setup({Scope scope}) {
    _scope = scope;
  }

  Future<void> log(String name, {Map<String, dynamic> params}) {
    return firebase.logEvent(name: name, parameters: params);
  }

  void configure({Function(String token) onToken, Function(Map<String, dynamic> message, MessageEventType event) onMessage}) {
    if (onToken != null) {
      _onToken = onToken;
    }
    if (onMessage != null) {
      _onMessage = onMessage;
    }
  }

  void _handleMessage(Map<String, dynamic> message, MessageEventType event) {
    var $title;
    var $body;

    if (message != null) {
      if (message['title'] != null) {
        $title = message['title'];
      } else if (message['data'] != null && message['data']['title'] != null) {
        $title = message['data']['title'];
      } else if (message['aps'] != null && message['aps']['alert'] != null && message['aps']['alert']['title'] != null) {
        $title = message['aps']['alert']['title'];
      }

      if (message['body'] != null) {
        $body = message['body'];
      } else if (message['data'] != null && message['data']['body'] != null) {
        $body = message['data']['body'];
      } else if (message['aps'] != null && message['aps']['body'] != null && message['aps']['alert']['body'] != null) {
        $body = message['aps']['alert']['body'];
      }
    }

    if (_scope != null && _scope.view.mounted == true && $title != null && $body != null) {
      _scope.alerts.notification($title, message: $body).show();
    }
    _onMessage?.call(message, event);
  }

  String get token => _token;

  FirebaseAnalytics get firebase => _analytics;

  FirebaseMessaging get messaging => _messaging;

  FirebaseAnalyticsObserver get observer => _observer;
}

enum MessageEventType { none, resume, launch }
