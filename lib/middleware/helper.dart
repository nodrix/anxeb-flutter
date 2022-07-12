import 'package:anxeb_flutter/anxeb.dart';

class ModelHelper {
  Scope _scope;
  Model _model;
  String _api;

  ModelHelper({Scope scope, Model model, String api}) {
    _scope = scope;
    _model = model;
    _api = api;
  }

  Future<bool> delete() async {
    var result = await _scope.dialogs.confirm(translate('anxeb.middleware.helper.delete_confirm')).show(); //TR ¿Estás seguro que quieres eliminar este registro?
    if (result) {
      try {
        await _scope.busy();
        await _application.api.delete('/$_api/${_model.$pk}');
        return true;
      } catch (err) {
        _scope.alerts.error(err).show();
      } finally {
        await _scope.idle();
      }
    }
    return false;
  }

  Application get _application => _scope.application;
}
