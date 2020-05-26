import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';
import '../logic/EmailController.dart';
import '../services/version1/EmailHttpServiceV1.dart';

class EmailServiceFactory extends Factory {
  static var ControllerDescriptor =
      Descriptor('pip-services-email', 'controller', 'default', '*', '1.0');
  static var HttpServiceDescriptor =
      Descriptor('pip-services-email', 'service', 'http', '*', '1.0');

  EmailServiceFactory() : super() {
    registerAsType(EmailServiceFactory.ControllerDescriptor, EmailController);
    registerAsType(
        EmailServiceFactory.HttpServiceDescriptor, EmailHttpServiceV1);
  }
}
