
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services_email/src/logic/logic.dart';
import 'package:pip_services_email/src/services/version1/services.dart';

class EmailServiceFactory extends Factory {
  static var ControllerDescriptor = new Descriptor('pip-services-email', 'controller', 'default', '*', '1.0');
  static var HttpServiceDescriptor = new Descriptor('pip-services-email', 'service', 'http', '*', '1.0');
  
  EmailServiceFactory() : super() {
    this.registerAsType(EmailServiceFactory.ControllerDescriptor, EmailController);
    this.registerAsType(EmailServiceFactory.HttpServiceDescriptor, EmailHttpServiceV1);
  }
}
