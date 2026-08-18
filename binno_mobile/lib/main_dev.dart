import 'package:binno_app/app/bootstrap/bootstrap.dart';
import 'package:binno_app/app/flavors/app_flavor.dart';

void main() {
  bootstrap(
    const AppEnvironment(
      flavor: AppFlavor.dev,
      apiBaseUrl: 'https://api-dev.example.com/api/v1',
    ),
  );
}
