import 'package:anxeb_flutter/anxeb.dart';

class Validators {
  String firstNames(String value) {
    var err = translate('anxeb.utils.validators.first_names.default_error'); // TR Ingrese uno o dos nombres válidos;
    var validCharacters = RegExp(r'^[^0-9_!¡?÷?¿/\\+=@#$%ˆ&*(){}|~<>;:[\]]{2,}$');
    var spaces = RegExp(r'\s\s');

    if (value != null && value.contains(validCharacters) && !value.contains(spaces)) {
      var parts = value.split(' ');
      if (parts.length > 7) {
        return err;
      }
      for (var item in parts) {
        if (item.length < 2) {
          return err;
        }
        if (item.length > 15) {
          return err;
        }
      }
    } else {
      return err;
    }
    return null;
  }

  String lastNames(String value) {
    if (firstNames(value) != null) {
      return translate('anxeb.utils.validators.last_names.default_error'); // TR 'Ingrese uno o dos apellidos válidos';
    } else {
      return null;
    }
  }

  String creditCard(String value) {
    if (value != null && CreditCardValidator.isCreditCardValid(cardNumber: value) == true) {
      return null;
    }
    return translate('anxeb.utils.validators.credit_card.default_error'); // TR 'Ingrese un número de tarjeta válido';
  }

  String creditCardCCV(String value) {
    if (value != null && value.length > 1 && value.length <= 4) {
      var ccv = int.tryParse(value);

      if (ccv != null && ccv >= 1 && ccv <= 9999) {
        return null;
      }
    }
    return translate('anxeb.utils.validators.credit_card.ccv_nnnn_error'); // TR 'Ingrese un código válido';
  }

  String fourDigitsPin(String value) {
    if (value != null && value.length == 4) {
      return null;
    }
    return translate('anxeb.utils.validators.pin.default_error'); // TR 'Debe ingresar 4 dígitos';
  }

  String creditCardCCV3Fix(String value) {
    if (value != null && value.length == 3) {
      var ccv = int.tryParse(value);
      if (ccv != null && ccv >= 0 && ccv <= 999) {
        return null;
      }
    }
    return translate('anxeb.utils.validators.credit_card.ccv_nnn_error'); // TR 'Ingrese un código válido';
  }

  String creditCardDateMMSYYYY(String value) {
    if (value != null && value.length == 7 && value.contains('/')) {
      var mm = value.substring(0, 2);
      var yyyy = value.substring(3, 7);

      var month = int.tryParse(mm);
      var year = int.tryParse(yyyy);

      if (month != null && month >= 1 && month <= 12) {
        if (year != null && year >= 1 && year <= 2999) {
          var date = DateTime.now();
          var exp = DateTime(year, month);

          if (!exp.isAfter(date)) {
            return translate('anxeb.utils.validators.credit_card.expired_date_error'); //Fecha de tarjeta expirada
          }

          return null;
        }
      }
    }
    return translate('anxeb.utils.validators.credit_card.mmsyyyy_date_error'); // TR 'Usar formato válido MM/YYYY';
  }

  String creditCardDateMMSYY(String value) {
    if (value != null && value.length == 5 && value.contains('/')) {
      var mm = value.substring(0, 2);
      var yy = value.substring(3, 5);

      var month = int.tryParse(mm);
      var year = int.tryParse('20$yy');

      if (month != null && month >= 1 && month <= 12) {
        if (year != null && year >= 1 && year <= 2999) {
          var date = DateTime.now();
          var exp = DateTime(year, month);

          if (!exp.isAfter(date)) {
            return translate('anxeb.utils.validators.credit_card.expired_date_error'); //Fecha de tarjeta expirada
          }

          return null;
        }
      }
    }
    return translate('anxeb.utils.validators.credit_card.mmsyy_date_error'); // TR 'Usar formato válido MM/YY';
  }

  String creditCardDateMMYY(String value) {
    if (value != null && value.length == 4) {
      var mm = value.substring(0, 2);
      var yy = value.substring(2, 4);

      var month = int.tryParse(mm);
      var year = int.tryParse('20$yy');

      if (month != null && month >= 1 && month <= 12) {
        if (year != null && year >= 1 && year <= 2999) {
          var date = DateTime.now();
          var exp = DateTime(year, month);

          if (!exp.isAfter(date)) {
            return translate('anxeb.utils.validators.credit_card.expired_date_error'); //Fecha de tarjeta expirada
          }

          return null;
        }
      }
    }
    return translate('anxeb.utils.validators.credit_card.mmyy_date_error'); // TR 'Usar formato válido MMYY';
  }

  String required(String value) {
    if (value == null || value.length == 0) {
      return translate('anxeb.utils.validators.required.default_error'); // TR 'Campo requirido';
    } else {
      return null;
    }
  }

  String somePercentRequired(String value) {
    var numb = Utils.convert.fromStringToDouble(value);

    if (numb == null || numb <= 0 || numb > 100.0) {
      return translate('anxeb.utils.validators.required.some_percent_error'); // TR 'Valor porcentual requerido';
    } else {
      return null;
    }
  }

  String greaterZero(String value) {
    var numb = Utils.convert.fromStringToDouble(value);

    if (numb == null || numb <= 0) {
      return translate('anxeb.utils.validators.required.numeric_error'); // TR 'Valor numérico requirido';
    } else {
      return null;
    }
  }

  String greaterZeroOrNothing(String value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    var numb = Utils.convert.fromStringToDouble(value);
    if (numb == null || numb <= 0) {
      return translate('anxeb.utils.validators.required.numeric_error'); // TR 'Valor numérico requirido';
    } else {
      return null;
    }
  }

  String barcode(String value) {
    if (value != null && value.isNotEmpty) {
      if (value.length > 1) {
        try {
          var mult = 3;
          var total = 0;
          for (var i = value.length - 2; i >= 0; i--) {
            total += (mult * int.parse(value[i]));
            mult = mult == 3 ? 1 : 3;
          }

          var totalStr = total.toString();
          var lastDigit = int.parse(totalStr[totalStr.length - 1]);
          var checkDigit = lastDigit > 0 ? 10 - lastDigit : 0;

          if (value.endsWith(checkDigit.toString())) {
            return null;
          }
        } catch (err) {}
      }
      return translate('anxeb.utils.validators.barcode.default_error'); // TR 'Código de barras inválido';
    } else {
      return null;
    }
  }

  String phone(String value) {
    Pattern pattern = r'^[0-9]*$';
    RegExp regex = new RegExp(pattern);
    if (value != null && regex.hasMatch(value)) {
      var phone = value.replaceAll('-', '');
      var number = 0;
      try {
        number = int.parse(phone);
        if (number.toString().length == 10 || number.toString().length == 11) {
          return null;
        }
      } catch (err) {}
    }

    return translate('anxeb.utils.validators.phone.default_error'); // TR 'Ingrese un número telefónico válido (solo números)';
  }

  String email(String value) {
    if (value == null || value.isEmpty) {
      return translate('anxeb.utils.validators.email.default_error'); // TR 'Correo requerido';
    } else {
      Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value)) {
        return translate('anxeb.utils.validators.email.invalid_error'); // TR 'Ingrese un correo válido';
      } else {
        return null;
      }
    }
  }

  String password(String value) {
    if (value == null || value.isEmpty) {
      return translate('anxeb.utils.validators.password.default_error'); // TR 'Contraseña requerida';
    } else {
      if (value.contains(' ')) {
        return translate('anxeb.utils.validators.password.space_error'); // TR 'Ingrese una contraseña sin espacios';
      }
      if (value.length < 5 || value.length > 16) {
        return translate('anxeb.utils.validators.password.length_error'); // TR 'Ingrese una contraseña entre 5 y 16 caracteres';
      }
    }
    return null;
  }

  String foreign(String value) {
    var msg = translate('anxeb.utils.validators.foreign.default_error'); // TR 'Ingrese una cédula extranjera (solo números)';
    if (value != null) {
      var ced = value.replaceAll(r'-', '').replaceAll(r' ', '').replaceAll(r'.', '').replaceAll(r'/', '');
      if (ced.length == 11 && cedula(ced) != null) {
        return null;
      }
    }
    return msg;
  }

  String cedula(String value) {
    var msg = translate('anxeb.utils.validators.cedula.default_error'); // TR 'Ingrese una cédula válida (solo números)';
    Pattern pattern = r'^[0-9]*$';
    RegExp regex = new RegExp(pattern);
    if (value != null && regex.hasMatch(value)) {
      if (value.length < 11) {
        return msg;
      }
      try {
        var c = value.replaceAll(r'-', '');
        var cedula = c.substring(0, c.length - 1);
        var verificador = int.parse(c.substring(c.length - 1));
        var suma = 0;
        var mod = 0;
        var res = -1;
        for (var i = 0; i < cedula.length; i++) {
          if ((i % 2) == 0) {
            mod = 1;
          } else {
            mod = 2;
          }
          res = int.parse(cedula.substring(i, i + 1)) * mod;
          if (res > 9) {
            var parts = res.toString();
            var uno = int.parse(parts.substring(0, 1));
            var dos = int.parse(parts.substring(1, 2));
            res = uno + dos;
          }
          suma += res;
        }
        var numero = (10 - (suma % 10)) % 10;
        if (numero == verificador && cedula.substring(0, 3) != '000') {
          return null;
        }
      } catch (x) {}
    }
    return msg;
  }

  String passport(String value) {
    var regex = new RegExp(r'^(?!^0+$)[a-zA-Z0-9]{6,9}$');
    if (value == null || !regex.hasMatch(value.trim())) {
      return translate('anxeb.utils.validators.passport.default_error'); // TR 'Ingrese un pasaporte válido';
    } else {
      return null;
    }
  }

  String posCode(String value) {
    var initial = ['A', 'B', 'C', 'D'];

    if (value == null || value.length < 2) {
      return translate('anxeb.utils.validators.pos_code.length_error'); // TR 'Ingrese un código mayor de 2 dígitos';
    } else if (!initial.contains(value[0].toUpperCase()) || int.tryParse(value.substring(1).replaceAll(' ', 'X').replaceAll('.', 'X').replaceAll('-', 'X')) == null) {
      return translate('anxeb.utils.validators.pos_code.starting_error'); // TR 'Ingrese un código inciado en A,B,C o D: ej.: C004';
    } else {
      return null;
    }
  }

  String identity(String value) {
    if (this.cedula(value) == null || this.passport(value) == null) {
      return null;
    } else {
      return translate('anxeb.utils.validators.identity.default_error'); // TR 'Ingrese un documento válido';
    }
  }
}
