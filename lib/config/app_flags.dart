import 'package:flutter/foundation.dart';

const String appEnv =
    String.fromEnvironment('APP_ENV', defaultValue: kReleaseMode ? 'prod' : 'dev');

const bool forceMockData =
    bool.fromEnvironment('USE_MOCK_DATA', defaultValue: false);

const bool isDevEnv = appEnv == 'dev';
const bool isStagingEnv = appEnv == 'staging';
const bool isProdEnv = appEnv == 'prod';

// En MVP, dev usa mock por defecto; staging/prod usan datos reales salvo override.
const bool useMockData = forceMockData || isDevEnv;

// Los indicadores visuales de modo demo solo se muestran en dev.
const bool showDemoIndicators = isDevEnv;
