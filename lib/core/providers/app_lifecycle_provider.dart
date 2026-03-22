import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLifecycleProvider = StateProvider<AppLifecycleStatus>((ref) {
  return AppLifecycleStatus.foreground;
});

enum AppLifecycleStatus { foreground, background, inactive }
