import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/app_dependencies.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ShiftCalendarEngineApp(dependencies: AppDependencies.production()));
}
