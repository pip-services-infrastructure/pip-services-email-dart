import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_rpc/pip_services3_rpc.dart';

class EmailHttpServiceV1 extends CommandableHttpService {
  EmailHttpServiceV1() : super('v1/email') {
    dependencyResolver.put('controller',
        Descriptor('pip-services-email', 'controller', 'default', '*', '1.0'));
  }
}
