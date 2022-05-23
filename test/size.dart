import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

void mockSize() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized()
          as TestWidgetsFlutterBinding;
  binding.window.physicalSizeTestValue = Size(360, 1000);
  binding.window.devicePixelRatioTestValue = 1.0;
}
