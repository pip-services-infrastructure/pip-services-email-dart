import 'package:pip_services3_container/pip_services3_container.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';
import '../build/EmailServiceFactory.dart';

class EmailProcess extends ProcessContainer {
  EmailProcess() : super('email', 'Email delivery microservice') {
    factories.add(EmailServiceFactory());
    factories.add(DefaultRpcFactory());
  }
}
