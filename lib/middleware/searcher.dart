import 'scope.dart';

class ViewSearcher {
  final Scope scope;
  final Future Function() action;
  final Future Function(dynamic err) completed;

  ViewSearcher({
    this.scope,
    this.action,
    this.completed,
  });
}
