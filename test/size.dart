import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

void mockSize() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  binding.window.physicalSizeTestValue = Size(360, 1000);
  binding.window.devicePixelRatioTestValue = 1.0;
}
