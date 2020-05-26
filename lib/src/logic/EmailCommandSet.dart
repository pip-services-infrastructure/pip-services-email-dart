import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../data/version1/data.dart';
import 'IEmailController.dart';

class EmailCommandSet extends CommandSet {
  IEmailController _logic;

  EmailCommandSet(IEmailController logic) : super() {
    _logic = logic;

    addCommand(_makeSendMessageCommand());
    addCommand(_makeSendMessageToRecipientCommand());
    addCommand(_makeSendMessageToRecipientsCommand());
  }

  ICommand _makeSendMessageCommand() {
    return Command(
        'send_message',
        ObjectSchema(true)
            .withRequiredProperty('message', EmailMessageV1Schema())
            .withOptionalProperty('parameters', TypeCode.Map),
        (String correlationId, Parameters args) {
      var message = EmailMessageV1();
      message.fromJson(args.get('message'));
      var parameters = ConfigParams.fromValue(args.get('parameters'));
      _logic.sendMessage(correlationId, message, parameters);
    });
  }

  ICommand _makeSendMessageToRecipientCommand() {
    return Command(
        'send_message_to_recipient',
        ObjectSchema(true)
            .withRequiredProperty('message', EmailMessageV1Schema())
            .withRequiredProperty('recipient', EmailRecipientV1Schema())
            .withOptionalProperty('parameters', TypeCode.Map),
        (String correlationId, Parameters args) {
      var message = EmailMessageV1();
      message.fromJson(args.get('message'));
      var recipient = EmailRecipientV1();
      recipient.fromJson(args.get('recipient'));
      var parameters = ConfigParams.fromValue(args.get('parameters'));

      _logic.sendMessageToRecipient(
          correlationId, recipient, message, parameters);
    });
  }

  ICommand _makeSendMessageToRecipientsCommand() {
    return Command(
        'send_message_to_recipients',
        ObjectSchema(true)
            .withRequiredProperty('message', EmailMessageV1Schema())
            .withRequiredProperty(
                'recipients', ArraySchema(EmailRecipientV1Schema()))
            .withOptionalProperty('parameters', TypeCode.Map),
        (String correlationId, Parameters args) {
      var message = EmailMessageV1();
      message.fromJson(args.get('message'));
      //var recipients = args.get("recipients");
      var recipients = List<EmailRecipientV1>.from(args
          .get('recipients')
          .map((itemsJson) => EmailRecipientV1.fromJson(itemsJson)));
      var parameters = ConfigParams.fromValue(args.get('parameters'));
      _logic.sendMessageToRecipients(
          correlationId, recipients, message, parameters);
    });
  }
}
