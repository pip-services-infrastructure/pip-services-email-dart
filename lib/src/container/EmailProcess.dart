
import 'package:pip_services3_container/pip_services3_container.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';
import 'package:pip_services_email/src/build/EmailServiceFactory.dart';

class EmailProcess extends ProcessContainer {
  EmailProcess() : super("email", "Email delivery microservice") {
    this.factories.add(new EmailServiceFactory());
    this.factories.add(new DefaultRpcFactory());
  }
}
