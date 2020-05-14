import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../data/version1/data.dart';
import 'IEmailController.dart';

class EmailCommandSet extends CommandSet {
  IEmailController _logic;

  EmailCommandSet(IEmailController logic) : super() {
    this._logic = logic;

    this.addCommand(this.makeSendMessageCommand());
    this.addCommand(this.makeSendMessageToRecipientCommand());
    this.addCommand(this.makeSendMessageToRecipientsCommand());
  }

  ICommand makeSendMessageCommand() {
    return Command(
        "send_message",
        new ObjectSchema(true)
            .withRequiredProperty('message', EmailMessageV1Schema())
            .withOptionalProperty('parameters', TypeCode.Map),
        (String correlationId, Parameters args) {
      var message = EmailMessageV1()..fromJson(args.get("message"));
      var parameters = ConfigParams()..fromJson(args.get("parameters"));
      this._logic.sendMessage(correlationId, message, parameters);
    });
  }

  ICommand makeSendMessageToRecipientCommand() {
    return Command(
        "send_message_to_recipient",
        new ObjectSchema(true)
            .withRequiredProperty('message', new EmailMessageV1Schema())
            .withRequiredProperty('recipient', new EmailRecipientV1Schema())
            .withOptionalProperty('parameters', TypeCode.Map),
        (String correlationId, Parameters args) {
      var message = EmailMessageV1()..fromJson(args.get("message"));
      var recipient = EmailRecipientV1()..fromJson(args.get("recipient"));
      var parameters = ConfigParams()..fromJson(args.get("parameters"));

      this._logic.sendMessageToRecipient(
          correlationId, recipient, message, parameters);
    });
  }

  ICommand makeSendMessageToRecipientsCommand() {
    return Command(
        "send_message_to_recipients",
        new ObjectSchema(true)
            .withRequiredProperty('message', new EmailMessageV1Schema())
            .withRequiredProperty(
                'recipients', new ArraySchema(new EmailRecipientV1Schema()))
            .withOptionalProperty('parameters', TypeCode.Map),
        (String correlationId, Parameters args) {
      var message = args.get("message");
      var recipients = args.get("recipients");
      var parameters = args.get("parameters");
      this._logic.sendMessageToRecipients(
          correlationId, recipients, message, parameters);
    });
  }
}
