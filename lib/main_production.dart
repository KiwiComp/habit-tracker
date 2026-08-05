import 'package:habit_tracker/app/app.dart';
import 'package:habit_tracker/bootstrap.dart';

Future<void> main() async {
  await bootstrap(environment: 'production', builder: () => const App());
}
