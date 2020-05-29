import 'dart:async';

import 'package:logging/logging.dart' as syslog;

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mustache4dart2/mustache4dart2.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services_email/src/data/version1/data.dart';

import 'EmailCommandSet.dart';
import 'IEmailController.dart';

class EmailController
    implements
        IConfigurable,
        IReferenceable,
        ICommandable,
        IOpenable,
        IEmailController {
  static final ConfigParams _defaultConfig = ConfigParams.fromTuples([
    'message.from',
    null,
    'message.cc',
    null,
    'message.bcc',
    null,
    'message.reply_to',
    null
  ]);

  ConfigParams _config;

  String _messageFrom;
  String _messageCc;
  String _messageBcc;
  String _messageReplyTo;
  ConfigParams _parameters = ConfigParams();

  ConnectionParams _connection;
  final ConnectionResolver _connectionResolver = ConnectionResolver();
  CredentialParams _credential;
  final CredentialResolver _credentialResolver = CredentialResolver();
  dynamic _transport;
  EmailCommandSet _commandSet;
  bool _disabled = false;

  final CompositeLogger _logger = CompositeLogger();

  /// Configures component by passing configuration parameters.
  ///
  /// - [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    syslog.Logger.root.level = syslog.Level.ALL; // defaults to Level.INFO
    syslog.Logger.root.onRecord.listen((record) {
      _logger.trace(
          null, '${record.level.name}: ${record.time}: ${record.message}');
    });

    _config = config.setDefaults(EmailController._defaultConfig);

    _messageFrom = config.getAsStringWithDefault('message.from', _messageFrom);
    _messageCc = config.getAsStringWithDefault('message.cc', _messageCc);
    _messageBcc = config.getAsStringWithDefault('message.bcc', _messageBcc);
    _messageReplyTo =
        config.getAsStringWithDefault('message.reply_to', _messageReplyTo);
    _parameters = config.getSection('parameters');
    _disabled = config.getAsBooleanWithDefault('options.disabled', _disabled);

    _connectionResolver.configure(config);
    _credentialResolver.configure(config);
  }

  /// Set references to component.
  ///
  /// - [references]    references parameters to be set.
  @override
  void setReferences(IReferences references) {
    _logger.setReferences(references);
    _connectionResolver.setReferences(references);
    _credentialResolver.setReferences(references);
  }

  /// Gets a command set.
  ///
  /// Return Command set
  @override
  CommandSet getCommandSet() {
    _commandSet ??= EmailCommandSet(this);
    return _commandSet;
  }

  /// Сhecks if SmtpServer is open
  ///
  /// Return bool checking result
  @override
  bool isOpen() {
    return _transport != null;
  }

  /// Creates the SmtpServer.
  ///
  /// - [correlationId] 	(optional) transaction id to trace execution through call chain.
  /// Return 			    Future that receives error or null no errors occured.
  @override
  Future<dynamic> open(String correlationId) async {
    if (_transport != null) {
      return;
    }

    _connection = await _connectionResolver.resolve(correlationId);
    _credential = await _credentialResolver.lookup(correlationId);

    if (_connection != null) {
      var host = _connection.getHost();
      var port = _connection.getPort();
      var ssl = _connection.getAsBoolean('ssl') ||
          _connection.getAsBoolean('secure') ||
          _connection.getAsBoolean('secure_connection');

      //String type = null;
      String user;
      String pass;

      if (_credential != null) {
        //type = _credential.getAsString("type");
        user = _credential.getUsername();
        pass = _credential.getPassword();
      }

      _transport = SmtpServer(host,
          port: port, ssl: ssl, username: user, password: pass);

      _logger.trace(correlationId,
          'Created smtp server: host = $host, port = $port, ssl = $ssl, username = $user');
    }
  }

  /// Closes the SmtpServer and frees used resources.
  ///
  /// - [correlationId] 	(optional) transaction id to trace execution through call chain.
  /// Return 			  Future that receives error or null no errors occured.
  @override
  Future<dynamic> close(String correlationId) async {
    _transport = null;
  }

  String getLanguageTemplate(dynamic value, [String language = 'en']) {
    if (value == null) return value;
    if (value is String) return value;

    // Set default language
    language = language ?? 'en';

    // Get template for specified language
    var template = value[language];

    // Get template for default language
    template ??= value['en'];

    return '' + template;
  }

  String renderTemplate(dynamic value, ConfigParams parameters,
      [String language = 'en']) {
    var template = getLanguageTemplate(value, language);
    return template != null ? render(template, parameters) : null;
  }

  /// Send the message
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [message]              a message to be send.
  /// - [parameters]              an additional parameters to be send.
  @override
  Future sendMessage(String correlationId, EmailMessageV1 message,
      ConfigParams parameters) async {
    // Silentry skip if disabled
    if (_disabled) {
      return;
    }

    // Skip processing if email is disabled or message has no destination
    if (_transport == null || message.to == null) {
      throw BadRequestException(correlationId, 'EMAIL_DISABLED',
          'emails disabled, or email recipient not set');
    }

    parameters = _parameters.override(parameters);

    try {
      var subject = renderTemplate(message.subject, parameters);
      var text = renderTemplate(message.text, parameters);
      var html = renderTemplate(message.html, parameters);
      var cc = message.cc ?? _messageCc;
      var bcc = message.bcc ?? _messageBcc;

      final envelop = Message()
        ..from = message.from ?? _messageFrom
        ..recipients.add(Address(message.to))
        ..subject = subject
        ..text = text
        ..html = html;

      if (cc != null && cc.isNotEmpty) envelop.ccRecipients.add(cc);
      if (bcc != null && bcc.isNotEmpty) envelop.bccRecipients.add(bcc);

      // replyTo: message.reply_to || _messageReplyTo,

      final report =
          await send(envelop, _transport, timeout: Duration(seconds: 15));

      _logger.trace(correlationId, report.toString());
    } on MailerException catch (ex) {
      _logger.error(correlationId, ex, 'Message not sent');
      for (var p in ex.problems) {
        _logger.trace(correlationId, 'Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  ConfigParams makeRecipientParameters(
      EmailRecipientV1 recipient, ConfigParams parameters) {
    parameters = _parameters.override(parameters);
    parameters.append(recipient);
    return parameters;
  }

  /// Send the message to recipient
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [recipient]              a recipient of the message.
  /// - [message]              a message to be send.
  /// - [parameters]              an additional parameters to be send.
  @override
  Future sendMessageToRecipient(
      String correlationId,
      EmailRecipientV1 recipient,
      EmailMessageV1 message,
      ConfigParams parameters) async {
    // Silentry skip if disabled
    if (_disabled) {
      return;
    }

    // Skip processing if email is disabled
    if (_transport == null || recipient == null || recipient.email == null) {
      throw BadRequestException(correlationId, 'EMAIL_DISABLED',
          'emails disabled, or recipients email not set');
    }

    try {
      var recParams = makeRecipientParameters(recipient, parameters);
      var recLanguage = recipient.language;

      var subject = renderTemplate(message.subject, recParams, recLanguage);
      var text = renderTemplate(message.text, recParams, recLanguage);
      var html = renderTemplate(message.html, recParams, recLanguage);
      var cc = message.cc ?? _messageCc;
      var bcc = message.bcc ?? _messageBcc;

      final envelop = Message()
        ..from = message.from ?? _messageFrom
        ..recipients.add(Address(recipient.email))
        ..subject = subject
        ..text = text
        ..html = html;

      if (cc != null && cc.isNotEmpty) envelop.ccRecipients.add(cc);
      if (bcc != null && bcc.isNotEmpty) envelop.bccRecipients.add(bcc);

      //replyTo: message.reply_to || _messageReplyTo,

      final report =
          await send(envelop, _transport, timeout: Duration(seconds: 15));

      _logger.trace(correlationId, report.toString());
    } on MailerException catch (ex) {
      _logger.error(correlationId, ex, 'Message not sent');
      for (var p in ex.problems) {
        _logger.trace(correlationId, 'Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  /// Send the message to recipients
  ///
  /// - [correlation_id]    (optional) transaction id to trace execution through call chain.
  /// - [recipients]              a recipients of the message.
  /// - [message]              a message to be send.
  /// - [parameters]              an additional parameters to be send.
  @override
  Future sendMessageToRecipients(
      String correlationId,
      List<EmailRecipientV1> recipients,
      EmailMessageV1 message,
      ConfigParams parameters) async {
    // Silentry skip if disabled
    if (_disabled) {
      return;
    }

    // Skip processing if email is disabled
    if (_transport == null || recipients == null || recipients.isEmpty) {
      throw BadRequestException(correlationId, 'EMAIL_DISABLED',
          'emails disabled, or no recipients sent');
    }

    // Send email separately to each user
    for (var recipient in recipients) {
      await sendMessageToRecipient(
          correlationId, recipient, message, parameters);
    }
  }
}
