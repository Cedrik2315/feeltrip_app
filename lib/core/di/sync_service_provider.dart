import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:feeltrip_app/services/sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});
