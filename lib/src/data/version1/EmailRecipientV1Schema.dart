import 'package:pip_services3_commons/pip_services3_commons.dart';

class EmailRecipientV1Schema extends ObjectSchema {
  EmailRecipientV1Schema() : super() {
    withRequiredProperty('id', TypeCode.String);
    withOptionalProperty('name', TypeCode.String);
    withOptionalProperty('email', TypeCode.String);
    withOptionalProperty('language', TypeCode.String);
  }
}
