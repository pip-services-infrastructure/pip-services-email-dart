import 'package:pip_services3_commons/pip_services3_commons.dart';

class EmailRecipientV1Schema extends ObjectSchema {
  EmailRecipientV1Schema() : super() {
    this.withRequiredProperty("id", TypeCode.String);
    this.withOptionalProperty("name", TypeCode.String);
    this.withOptionalProperty("email", TypeCode.String);
    this.withOptionalProperty("language", TypeCode.String);
  }
}
