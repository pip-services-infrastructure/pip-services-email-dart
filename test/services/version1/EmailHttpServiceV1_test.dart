
import 'dart:convert';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services_email/pip_services_email.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

var httpConfig = ConfigParams.fromTuples([
    "connection.protocol", "http",
    "connection.host", "localhost",
    "connection.port", 3000
]);

void main() {
group('EmailHttpServiceV1', () {
    EmailHttpServiceV1 service;

    http.Client rest;
    String url;

    setUp(() async {
        url = 'http://localhost:3000';
        rest = http.Client();

        var controller = new EmailController();

        controller.configure(ConfigParams.fromTuples([
            'options.disabled', true
        ]));

        service = new EmailHttpServiceV1();
        service.configure(httpConfig);

        var references = References.fromTuples([
            new Descriptor('pip-services-email', 'controller', 'default', 'default', '1.0'), controller,
            new Descriptor('pip-services-email', 'service', 'http', 'default', '1.0'), service
        ]);
        controller.setReferences(references);
        service.setReferences(references);

        await controller.open(null);
        await service.open(null);
    });
    
    tearDown(() async {
        await service.close(null);
    });

    test('Send message', () async {
        var resp = await rest.post(url + '/v1/email/send_message',
            headers: {'Content-Type': 'application/json'},
            body : json.encode({
                'message': EmailMessageV1()..fromJson({
                    'to': 'pipdevs@gmail.com',
                    'subject': 'Test message',
                    'text': 'This is a test message'
                })}));

        expect(resp, isNotNull);
        expect(resp.statusCode ~/ 100, 2);
    });
});
}