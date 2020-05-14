import 'package:pip_services3_commons/pip_services3_commons.dart';

class EmailMessageV1Schema extends ObjectSchema {
  EmailMessageV1Schema() : super() {
    this.withOptionalProperty("from", TypeCode.String);
    this.withOptionalProperty("cc", TypeCode.String);
    this.withOptionalProperty("bcc", TypeCode.String);
    this.withOptionalProperty("to", TypeCode.String);
    this.withOptionalProperty("reply_to", TypeCode.String);
    this.withOptionalProperty("subject", null);
    this.withOptionalProperty("text", null);
    this.withOptionalProperty("html", null);
  }
}
