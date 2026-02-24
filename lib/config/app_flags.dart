import 'package:flutter/foundation.dart';

const bool useMockData =
    bool.fromEnvironment('USE_MOCK_DATA', defaultValue: !kReleaseMode);
