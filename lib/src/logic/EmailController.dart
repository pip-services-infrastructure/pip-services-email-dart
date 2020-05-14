
/*
var _ = require('lodash');
var async = require('async');
var mustache = require('mustache');

import { ConfigParams } from 'pip-services3-commons-node';
import { IConfigurable } from 'pip-services3-commons-node';
import { IReferences } from 'pip-services3-commons-node';
import { Descriptor } from 'pip-services3-commons-node';
import { IReferenceable } from 'pip-services3-commons-node';
import { DependencyResolver } from 'pip-services3-commons-node';
import { ConnectionParams } from 'pip-services3-components-node';
import { ConnectionResolver } from 'pip-services3-components-node';
import { CredentialParams } from 'pip-services3-components-node';
import { CredentialResolver } from 'pip-services3-components-node';
import { ICommandable } from 'pip-services3-commons-node';
import { CommandSet } from 'pip-services3-commons-node';
import { BadRequestException } from 'pip-services3-commons-node';
import { IOpenable } from 'pip-services3-commons-node';

import { EmailMessageV1 } from '../data/version1/EmailMessageV1';
import { EmailRecipientV1 } from '../data/version1/EmailRecipientV1';
import { IEmailController } from './IEmailController';
import { EmailCommandSet } from './EmailCommandSet';
*/

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

class EmailController implements IConfigurable, IReferenceable, ICommandable, IOpenable, IEmailController {
    static final ConfigParams _defaultConfig = ConfigParams.fromTuples([
        'message.from', null,
        'message.cc', null,
        'message.bcc', null,
        'message.reply_to', null
    ]);

    ConfigParams _config;

    String _messageFrom;
    String _messageCc;
    String _messageBcc;
    String _messageReplyTo;
    ConfigParams _parameters = new ConfigParams();

    ConnectionParams _connection;
    ConnectionResolver _connectionResolver = new ConnectionResolver();
    CredentialParams _credential;
    CredentialResolver _credentialResolver = new CredentialResolver();
    dynamic _transport;
    EmailCommandSet _commandSet;
    bool _disabled = false;

    CompositeLogger _logger = CompositeLogger();

    void configure(ConfigParams config) {

        syslog.Logger.root.level = syslog.Level.ALL; // defaults to Level.INFO
        syslog.Logger.root.onRecord.listen((record) {
          _logger.trace(null, '${record.level.name}: ${record.time}: ${record.message}');
        });

        this._config = config.setDefaults(EmailController._defaultConfig);

        this._messageFrom = config.getAsStringWithDefault("message.from", this._messageFrom);
        this._messageCc = config.getAsStringWithDefault("message.cc", this._messageCc);
        this._messageBcc = config.getAsStringWithDefault("message.bcc", this._messageBcc);
        this._messageReplyTo = config.getAsStringWithDefault("message.reply_to", this._messageReplyTo);
        this._parameters = config.getSection("parameters");
        this._disabled = config.getAsBooleanWithDefault("options.disabled", this._disabled);

        this._connectionResolver.configure(config);
        this._credentialResolver.configure(config);
    }

    void setReferences(IReferences references) {
        this._logger.setReferences(references);
        this._connectionResolver.setReferences(references);
        this._credentialResolver.setReferences(references);
    }

    CommandSet getCommandSet() {
        if (this._commandSet == null)
            this._commandSet = new EmailCommandSet(this);
        return this._commandSet;
    }

    bool isOpen() {
        return this._transport != null;
    }

    Future<dynamic> open(String correlationId) async {
        if (this._transport != null) {
            return;
        }

        this._connection = await this._connectionResolver.resolve(correlationId);
        this._credential = await this._credentialResolver.lookup(correlationId);

        if (this._connection != null) {
            String host = this._connection.getHost();
            int port = this._connection.getPort();
            bool ssl = this._connection.getAsBoolean('ssl')
                    || this._connection.getAsBoolean('secure')
                    || this._connection.getAsBoolean('secure_connection');

            String type = null;
            String user = null;
            String pass = null;

            if (this._credential != null) {
                    type = this._credential.getAsString("type");
                    user = this._credential.getUsername();
                    pass = this._credential.getPassword();
            }

            this._transport = SmtpServer(
              host, 
              port: port, 
              ssl: ssl, 
              username: user, 
              password: pass);

            _logger.trace(correlationId, 'Created smtp server: host = $host, port = $port, ssl = $ssl, username = $user');
        }
    }

    Future<dynamic> close(String correlationId) async {
        this._transport = null;
    }

    String getLanguageTemplate(dynamic value, [String language = 'en' ]) {
        if (value == null) return value;
        if (value is String) return value;

        // Set default language
        language = language ?? "en";

        // Get template for specified language
        var template = value[language];

        // Get template for default language
        if (template == null)
            template = value["en"];

        return '' + template;
    }

    String renderTemplate(dynamic value, ConfigParams parameters, [String language = 'en' ]) {
        var template = this.getLanguageTemplate(value, language);
        return template != null ? render(template, parameters) : null;
    }

    Future<void> sendMessage(String correlationId, EmailMessageV1 message, ConfigParams parameters) async {

        // Silentry skip if disabled
        if (this._disabled) {
            return;
        }

        // Skip processing if email is disabled or message has no destination
        if (this._transport == null || message.to == null) {
            throw new BadRequestException(
                correlationId,
                'EMAIL_DISABLED',
                'emails disabled, or email recipient not set'
            );
        }

        parameters = this._parameters.override(parameters);

        try {

          String subject = this.renderTemplate(message.subject, parameters);
          String text = this.renderTemplate(message.text, parameters);
          String html = this.renderTemplate(message.html, parameters);
          String cc = message.cc ?? this._messageCc;
          String bcc = message.bcc ?? this._messageBcc;

          final envelop = Message()
              ..from = message.from ?? this._messageFrom
              ..recipients.add(Address(message.to))
              ..subject = subject
              ..text = text
              ..html = html;

          if (cc != null && cc.isNotEmpty) envelop.ccRecipients.add(cc);
          if (bcc != null && bcc.isNotEmpty) envelop.bccRecipients.add(bcc);

          // replyTo: message.reply_to || this._messageReplyTo,

          final report = await send(envelop, _transport, timeout: Duration(seconds: 15));
          
          _logger.trace(correlationId, report.toString());

        } on MailerException catch (ex) {
          _logger.error(correlationId, ex, 'Message not sent');
          for (var p in ex.problems) {
            _logger.trace(correlationId, 'Problem: ${p.code}: ${p.msg}');
          }
        }
    }

    ConfigParams makeRecipientParameters(EmailRecipientV1 recipient, ConfigParams parameters) {
        parameters = this._parameters.override(parameters);
        parameters.append(recipient);
        return parameters;
    }

    Future<void> sendMessageToRecipient(String correlationId, EmailRecipientV1 recipient, EmailMessageV1 message, ConfigParams parameters) async {

        // Silentry skip if disabled
        if (this._disabled) {
            return;
        }

        // Skip processing if email is disabled
        if (this._transport == null || recipient == null || recipient.email == null) {
            throw new BadRequestException(
                correlationId,
                'EMAIL_DISABLED',
                'emails disabled, or recipients email not set'
            );
        }

        try {
            var recParams = this.makeRecipientParameters(recipient, parameters);
            var recLanguage = recipient.language;

            String subject = this.renderTemplate(message.subject, recParams, recLanguage);
            String text = this.renderTemplate(message.text, recParams, recLanguage);
            String html = this.renderTemplate(message.html, recParams, recLanguage);
            String cc = message.cc ?? this._messageCc;
            String bcc = message.bcc ?? this._messageBcc;

            final envelop = Message()
                ..from = message.from ?? this._messageFrom
                ..recipients.add(Address(recipient.email))
                ..subject = subject
                ..text = text
                ..html = html;

            if (cc != null && cc.isNotEmpty) envelop.ccRecipients.add(cc);
            if (bcc != null && bcc.isNotEmpty) envelop.bccRecipients.add(bcc);

            //replyTo: message.reply_to || this._messageReplyTo,

            final report = await send(envelop, _transport, timeout: Duration(seconds: 15));
          
            _logger.trace(correlationId, report.toString());

        } on MailerException catch (ex) {
          _logger.error(correlationId, ex, 'Message not sent');
          for (var p in ex.problems) {
            _logger.trace(correlationId, 'Problem: ${p.code}: ${p.msg}');
          }
        }
    }

    Future<void> sendMessageToRecipients(String correlationId, List<EmailRecipientV1> recipients, EmailMessageV1 message, ConfigParams parameters) async {

        // Silentry skip if disabled
        if (this._disabled) {
            return;
        }

        // Skip processing if email is disabled
        if (this._transport == null || recipients == null || recipients.length == 0) {
            throw new BadRequestException(
                correlationId,
                'EMAIL_DISABLED',
                'emails disabled, or no recipients sent'
            );
        }

        // Send email separately to each user
        for (var recipient in recipients) {
          await this.sendMessageToRecipient(correlationId, recipient, message, parameters);
        }
    }
}
