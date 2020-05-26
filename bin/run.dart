import 'package:pip_services_email/pip_services_email.dart';

void main(List<String> args) {
  try {
    var proc = EmailProcess();
    proc.configPath = './config/config.yml';
    proc.run(args);
  } catch (ex) {
    print(ex);
  }
}
