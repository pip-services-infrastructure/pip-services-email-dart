import 'dart:io';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services_email/pip_services_email.dart';
import 'package:test/test.dart';

void main()
{
group('EmailController', () {
    EmailController controller;

    var emailHost = Platform.environment['EMAIL_HOST'] ?? "smtp@gmail.com";
    var emailPort = Platform.environment['EMAIL_PORT'] ?? 465;
    var emailSsl = Platform.environment['EMAIL_SSL'] ?? true;
    var emailUser = Platform.environment['EMAIL_USER'];
    var emailPassword = Platform.environment['EMAIL_PASS'];

    var messageFrom = Platform.environment['MESSAGE_FROM'] ?? "somebody@somewhere.com";
    var messageTo = Platform.environment['MESSAGE_TO'];

    // if (emailUser == null) return;

    setUp(() async {
        controller = EmailController();

        var config = ConfigParams.fromTuples([
            "message.from", messageFrom,

            "connection.host", emailHost,
            "connection.port", emailPort,
            "connection.ssl", emailSsl,

            "credential.username", emailUser,
            "credential.password", emailPassword,

            "options.disabled", emailUser == null || messageTo == null
        ]);
        controller.configure(config);

        await controller.open(null);
    });

    tearDown(() async {
        await controller.close(null);
    });

    test('Send Message to Address', () async {
        var message =  EmailMessageV1()..fromJson({
            'to': messageTo,
            'subject': '{{subject}}',
            'text': '{{text}}',
            'html': '<p>{{text}}</p>'
        });

        var parameters = ConfigParams.fromTuples([
            'subject', 'Test Email To Address',
            'text', 'This is just a test'
        ]);

        await controller.sendMessage(null, message, parameters);
    });

    test('Send Message to Recipient', () async {
        var message =  EmailMessageV1()..fromJson({
            'subject': 'Test Email To Recipient',
            'text': 'This is just a test'
        });

        var recipient = EmailRecipientV1()..fromJson({
            'id': '1',
            'email': messageTo,
            'name': 'Test Recipient'
        });

        await controller.sendMessageToRecipient(null, recipient, message, null);
    });
});
}