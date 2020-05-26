import 'package:pip_services3_commons/pip_services3_commons.dart';

class EmailMessageV1Schema extends ObjectSchema {
  EmailMessageV1Schema() : super() {
    withOptionalProperty('from', TypeCode.String);
    withOptionalProperty('cc', TypeCode.String);
    withOptionalProperty('bcc', TypeCode.String);
    withOptionalProperty('to', TypeCode.String);
    withOptionalProperty('reply_to', TypeCode.String);
    withOptionalProperty('subject', null);
    withOptionalProperty('text', null);
    withOptionalProperty('html', null);
  }
}
