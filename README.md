# Email Delivery Microservice

This is a email delivery microservice from Pip.Services library. 
This microservice sends emails to specified recipients.

The microservice currently supports the following deployment options:
* Deployment platforms: Standalone Process
* External APIs: HTTP/REST

<a name="links"></a> Quick Links:

* [Download Links](doc/Downloads.md)
* [Development Guide](doc/Development.md)
* [Configuration Guide](doc/Configuration.md)
* [Deployment Guide](doc/Deployment.md)
* Client SDKs
  - [Dart SDK](https://github.com/pip-services-infrastructure/pip-clients-email-dart)
* Communication Protocols
  - [HTTP Version 1](doc/HttpProtocolV1.md)

##  Contract

Logical contract of the microservice is presented below. For physical implementation (HTTP/REST, Thrift, Seneca, Lambda, etc.),
please, refer to documentation of the specific protocol.

```dart
class EmailMessageV1 {
  String from;
  String cc;
  String bcc;
  String to;
  String reply_to;
  dynamic subject;
  dynamic text;
  dynamic html;
}

class EmailRecipientV1 {
  String id;
  String name;
  String email;
  String language;
}

abstract class IEmailV1 {
  Future sendMessage(String correlationId, EmailMessageV1 message, ConfigParams parameters);

  Future sendMessageToRecipient(String correlationId, EmailRecipientV1 recipient, EmailMessageV1 message, ConfigParams parameters);

  Future sendMessageToRecipients(String correlationId, List<EmailRecipientV1> recipients, EmailMessageV1 message, ConfigParams parameters);
}
```

Message subject, text and html content can be set by handlebars template, that it processed using parameters set. Here is an example of the template:

```html
Dear {{ name }},
<p/>
Please, help us to verify your email address. Your verification code is {{ code }}.
<p/>
Click on the 
<a href="{{ clientUrl }}/#/verify_email?server_url={{ serverUrl }}&email={{ email }}&code={{ code }}">link</a>
to complete verification procedure
<p/>
---<br/>
{{ signature }}
```

## Download

Right now the only way to get the microservice is to check it out directly from github repository
```bash
git clone git@github.com:pip-services-infrastructure/pip-services-email-dart.git
```

Pip.Service team is working to implement packaging and make stable releases available for your 
as zip downloadable archieves.

## Run

Add **config.yml** file to the root of the microservice folder and set configuration parameters.
As the starting point you can use example configuration from **config.example.yml** file. 
Example of microservice configuration
```yaml
---
- descriptor: "pip-services-commons:logger:console:default:1.0"
  level: "trace"

- descriptor: "pip-services-email:controller:default:default:1.0"
  message:
    from: 'somebody@somewhere.com'
    to: 'somebody@somewhere.com'
  connection:
    service: 'Gmail'
    host: 'smtp.gmail.com'
    secure_connection: true
    port: 465
  credential:
    username: 'somebody@gmail.com'
    password: 'pass123'
  
- descriptor: "pip-services-email:service:http:default:1.0"
  connection:
    protocol: "http"
    host: "0.0.0.0"
    port: 8080
```
 
For more information on the microservice configuration see [Configuration Guide](Configuration.md).

Start the microservice using the command:
```bash
dart ./bin/run.dart
```

## Use

The easiest way to work with the microservice is to use client SDK. 
The complete list of available client SDKs for different languages is listed in the [Quick Links](#links)

If you use dart, then get references to the required libraries:
- Pip.Services3.Commons : https://github.com/pip-services3-dart/pip-services3-commons-dart
- Pip.Services3.Rpc: https://github.com/pip-services3-dart/pip-services3-rpc-dart


Add **pip-services3-commons-dart**, **pip-services3-rpc-dart** and **pip-services_email** packages
```dart
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';

import 'package:pip_services_email/pip_services_email.dart';

```

Define client configuration parameters that match configuration of the microservice external API
```dart
// Client configuration
var config = ConfigParams.fromTuples(
	"connection.protocol", "http",
	"connection.host", "localhost",
	"connection.port", 8080
);
```

Instantiate the client and open connection to the microservice
```dart
// Create the client instance
var client = EmailHttpClientV1(config);

// Connect to the microservice
await client.open(null);
    
    // Work with the microservice
    ...
});
```

Now the client is ready to perform operations
```dart
// Send email message to address
var message = EmailMessageV1(to: 'somebody@somewhere.com', 
                             subject: 'Test', 
                             text: 'This is a test message. Please, ignore it');
var parameters = ConfigParams.fromTuples(
                             ['subject', 'Test Email To Address', 'text', 'This is just a test']);

await client.sendMessage(
    null,
    message,
    parameters
);
```

```dart
// Send email message to users
var recipient1 = EmailRecipientV1(id: '1', email: 'user1@somewhere.com');
var recipient2 = EmailRecipientV1(id: '2', email: 'user2@somewhere.com');
var message = EmailMessageV1(subject: 'Test', 
                             text: 'This is a test message. Please, ignore it');
await client.sendMessageToRecipients(
    null,
    [
        recipient1,
        recipient2
    ],
    message,
    null
);
```

## Acknowledgements

This microservice was created and currently maintained by
- **Sergey Seroukhov**
- **Denis Kuznetsov**
- **Nuzhnykh Egor**.