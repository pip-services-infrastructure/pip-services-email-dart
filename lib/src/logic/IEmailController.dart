import 'dart:async';

import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../data/version1/data.dart';

abstract class IEmailController {
  Future<void> sendMessage(String correlationId, EmailMessageV1 message, ConfigParams parameters);
  Future<void> sendMessageToRecipient(String correlationId, EmailRecipientV1 recipient, EmailMessageV1 message, ConfigParams parameters);
  Future<void> sendMessageToRecipients(String correlationId, List<EmailRecipientV1> recipients, EmailMessageV1 message, ConfigParams parameters);
}
