import 'package:anxeb_flutter/anxeb.dart';

class Validators {
  String firstNames(String value) {
    var err = 'Ingrese uno o dos nombres válidos';
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
      return 'Ingrese uno o dos apellidos válidos';
    } else {
      return null;
    }
  }

  String creditCard(String value) {
    if (value != null && CreditCardValidator.isCreditCardValid(cardNumber: value) == true) {
      return null;
    }
    return 'Ingrese un número de tarjeta válido';
  }

  String creditCardCCV(String value) {
    if (value != null && value.length > 1 && value.length <= 4) {
      var ccv = int.tryParse(value);

      if (ccv != null && ccv >= 1 && ccv <= 9999) {
        return null;
      }
    }
    return 'Ingrese un código válido';
  }

  String creditCardDate(String value) {
    if (value != null && value.length == 4) {
      var mm = value.substring(0, 2);
      var yy = value.substring(2, 4);

      var month = int.tryParse(mm);
      var year = int.tryParse(yy);

      if (month != null && month >= 1 && month <= 12) {
        if (year != null && year >= 1 && year <= 99) {
          return null;
        }
      }
    }
    return 'Usar formato válido MMYY';
  }

  String required(String value) {
    if (value == null || value.length == 0) {
      return 'Campo requirido';
    } else {
      return null;
    }
  }

  String greaterZero(String value) {
    var numb = Utils.convert.fromStringToDouble(value);

    if (numb == null || numb <= 0) {
      return 'Valor numérico requirido';
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
      return 'Valor numérico requirido';
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
      return 'Código de barras inválido';
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

    return 'Ingrese un número telefónico válido (solo números)';
  }

  String email(String value) {
    if (value == null || value.isEmpty) {
      return 'Correo requerido';
    } else {
      Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value)) {
        return 'Ingrese un correo válido';
      } else {
        return null;
      }
    }
  }

  String password(String value) {
    if (value == null || value.isEmpty) {
      return 'Contraseña requerida';
    } else {
      if (value.contains(' ')) {
        return 'Ingrese una contraseña sin espacios';
      }
      if (value.length < 5 || value.length > 16) {
        return 'Ingrese una contraseña entre 5 y 16 caracteres';
      }
    }
    return null;
  }

  String foreign(String value) {
    var msg = 'Ingrese una cédula extranjera (solo números)';
    if (value != null) {
      var ced = value.replaceAll(r'-', '').replaceAll(r' ', '').replaceAll(r'.', '').replaceAll(r'/', '');
      if (ced.length == 11 && cedula(ced) != null) {
        return null;
      }
    }
    return msg;
  }

  String cedula(String value) {
    var msg = 'Ingrese una cédula válida (solo números)';
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
      return 'Ingrese un pasaporte válido';
    } else {
      return null;
    }
  }

  String posCode(String value) {
    var initial = ['A', 'B', 'C', 'D'];

    if (value == null || value.length < 2) {
      return 'Ingrese un código mayor de 2 dígitos';
    } else if (!initial.contains(value[0].toUpperCase()) || int.tryParse(value.substring(1).replaceAll(' ', 'X').replaceAll('.', 'X').replaceAll('-', 'X')) == null) {
      return 'Ingrese un código inciado en A,B,C o D: ej.: C004';
    } else {
      return null;
    }
  }

  String identity(String value) {
    if (this.cedula(value) == null || this.passport(value) == null) {
      return null;
    } else {
      return 'Ingrese un documento válido';
    }
  }
}
