import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:feeltrip_app/services/chronicle_service.dart';
import 'package:feeltrip_app/services/chronicle_repository.dart';
import 'package:feeltrip_app/models/expedition_data.dart';
import 'package:feeltrip_app/features/auth/presentation/providers/auth_notifier.dart';
import 'package:feeltrip_app/services/isar_service.dart';
import 'package:feeltrip_app/core/logger/app_logger.dart';
import 'package:feeltrip_app/models/chronicle_model.dart';

/// API key inyectada desde flutter_dotenv.
final chronicleApiKeyProvider = Provider<String>((_) {
  throw UnimplementedError('Provee la API key via override en ProviderScope dentro de main.dart');
});

final chronicleServiceProvider = Provider<ChronicleService>((ref) {
  final key = ref.watch(chronicleApiKeyProvider);
  return ChronicleService(apiKey: key);
});

final chronicleRepositoryProvider = Provider<ChronicleRepository>((ref) {
  final service = ref.watch(chronicleServiceProvider);
  final hiveService = ref.read(isarServiceProvider);
  return ChronicleRepositoryImpl(service: service, hiveService: hiveService);
});

/// Estado de lista (offline, siempre disponible)
final chronicleListProvider =
    NotifierProvider<ChronicleListNotifier, List<ChronicleModel>>(
  ChronicleListNotifier.new,
);

class ChronicleListNotifier extends Notifier<List<ChronicleModel>> {
  @override
  List<ChronicleModel> build() {
    final repo = ref.watch(chronicleRepositoryProvider);
    return repo.getAll();
  }

  void refresh() {
    state = ref.read(chronicleRepositoryProvider).getAll();
  }

  Future<void> delete(String id) async {
    await ref.read(chronicleRepositoryProvider).delete(id);
    refresh();
  }
}

/// Estado de generación (async, requiere conexión)
final chronicleGeneratorProvider =
    AsyncNotifierProvider<ChronicleGeneratorNotifier, ChronicleModel?>(
  ChronicleGeneratorNotifier.new,
);

class ChronicleGeneratorNotifier extends AsyncNotifier<ChronicleModel?> {
  @override
  Future<ChronicleModel?> build() async => null;

  /// Llama a la API, guarda en Hive y refresca la lista.
  Future<void> generate(ExpeditionData data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(chronicleRepositoryProvider);
      final authState = ref.read(authNotifierProvider);
      final userId = authState.value?.id ?? 'guest_user';
      final chronicle = await repo.generateAndSave(data: data, userId: userId);
      ref.read(chronicleListProvider.notifier).refresh();
      return chronicle;
    });
  }

  void reset() => state = const AsyncData(null);
}

/// Repositorio que orquesta generación + persistencia en Hive.
/// Implementa el flujo Offline-First: API -> Local (Hive) -> SyncService (Firestore).
class ChronicleRepositoryImpl implements ChronicleRepository {
  ChronicleRepositoryImpl({
    required ChronicleService service,
    required IsarService hiveService,
  })  : _service = service,
        _isar = hiveService {
    _box = _isar.chroniclesBox;
    _metaBox = _isar.metaBox;
  }

  static const String _counterKey = '__expedition_counter__';

  final ChronicleService _service;
  final IsarService _isar;
  late final Box<ChronicleModel> _box;
  late final Box<dynamic> _metaBox;

  @override
  Future<ChronicleModel> generateAndSave({
    required ExpeditionData data,
    required String userId,
  }) async {
    try {
      final number = await _nextExpeditionNumber(userId);

      final chronicle = await _service.generateChronicle(
        data: data,
        userId: userId,
        expeditionNumber: number,
      );

      _box.put(chronicle.id, chronicle);

      AppLogger.i('ChronicleRepository: Crónica #${chronicle.expeditionNumber} guardada localmente.');
      return chronicle;
    } catch (e) {
      AppLogger.e('ChronicleRepository Error: $e');
      rethrow;
    }
  }

  @override
  List<ChronicleModel> getAll() {
    final list = _box.values.toList();
    list.sort((ChronicleModel a, ChronicleModel b) => b.generatedAt.compareTo(a.generatedAt));
    return list;
  }

  @override
  Future<void> delete(String id) async {
    _box.delete(id);
  }

  Future<int> _nextExpeditionNumber(String userId) async {
    final key = '${userId}_$_counterKey';
    final rawCurrent = _metaBox.get(key);
    int current = (rawCurrent as int?) ?? 100;
    int next = current + 1;
    _metaBox.put(key, next);
    return next;
  }
}
