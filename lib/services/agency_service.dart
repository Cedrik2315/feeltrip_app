import '../config/app_flags.dart';
import '../core/app_logger.dart';
import '../models/agency_model.dart';
import '../repositories/agency_repository.dart';

class AgencyService {
  AgencyService({AgencyRepository? repository})
      : _repository = repository ??
            (useMockData
                ? MockAgencyRepository()
                : FirestoreAgencyRepository());

  final AgencyRepository _repository;

  Future<String> createAgency(TravelAgency agency) async {
    try {
      return await _repository.createAgency(agency);
    } catch (e, st) {
      AppLogger.error('Error en AgencyService.createAgency',
          error: e, stackTrace: st, name: 'AgencyService');
      rethrow;
    }
  }

  Future<TravelAgency?> getAgencyById(String agencyId) async {
    try {
      return await _repository.getAgencyById(agencyId);
    } catch (e, st) {
      AppLogger.error('Error en AgencyService.getAgencyById',
          error: e, stackTrace: st, name: 'AgencyService');
      return null;
    }
  }

  Stream<List<TravelAgency>> getAllAgencies() {
    return _repository.getAllAgencies();
  }

  Stream<List<TravelAgency>> getAgenciesByCity(String city) {
    return _repository.getAgenciesByCity(city);
  }

  Stream<List<TravelAgency>> getAgenciesBySpecialty(String specialty) {
    return _repository.getAgenciesBySpecialty(specialty);
  }

  Future<void> updateAgency(String agencyId, Map<String, dynamic> data) async {
    try {
      await _repository.updateAgency(agencyId, data);
    } catch (e, st) {
      AppLogger.error('Error en AgencyService.updateAgency',
          error: e, stackTrace: st, name: 'AgencyService');
      rethrow;
    }
  }

  Future<void> addExperienceToAgency({
    required String agencyId,
    required String experienceId,
  }) async {
    try {
      await _repository.addExperienceToAgency(
          agencyId: agencyId, experienceId: experienceId);
    } catch (e, st) {
      AppLogger.error('Error en AgencyService.addExperienceToAgency',
          error: e, stackTrace: st, name: 'AgencyService');
      rethrow;
    }
  }

  Future<void> followAgency(String agencyId) async {
    try {
      await _repository.followAgency(agencyId);
    } catch (e, st) {
      AppLogger.error('Error en AgencyService.followAgency',
          error: e, stackTrace: st, name: 'AgencyService');
      rethrow;
    }
  }

  Future<void> followAgencyWithUser({
    required String userId,
    required String agencyId,
  }) async {
    try {
      await _repository.followAgencyWithUser(
          userId: userId, agencyId: agencyId);
    } catch (e, st) {
      AppLogger.error('Error en AgencyService.followAgencyWithUser',
          error: e, stackTrace: st, name: 'AgencyService');
      rethrow;
    }
  }

  Future<void> unfollowAgencyWithUser({
    required String userId,
    required String agencyId,
  }) async {
    try {
      await _repository.unfollowAgencyWithUser(
          userId: userId, agencyId: agencyId);
    } catch (e, st) {
      AppLogger.error('Error en AgencyService.unfollowAgencyWithUser',
          error: e, stackTrace: st, name: 'AgencyService');
      rethrow;
    }
  }

  Future<bool> isFollowingAgency({
    required String userId,
    required String agencyId,
  }) async {
    try {
      return await _repository.isFollowingAgency(
          userId: userId, agencyId: agencyId);
    } catch (e, st) {
      AppLogger.error('Error en AgencyService.isFollowingAgency',
          error: e, stackTrace: st, name: 'AgencyService');
      return false;
    }
  }

  Future<List<String>> getFollowingAgencies(String userId) async {
    try {
      return await _repository.getFollowingAgencies(userId);
    } catch (e, st) {
      AppLogger.error('Error en AgencyService.getFollowingAgencies',
          error: e, stackTrace: st, name: 'AgencyService');
      return [];
    }
  }

  Future<void> updateAgencyRating({
    required String agencyId,
    required double newRating,
  }) async {
    try {
      await _repository.updateAgencyRating(
          agencyId: agencyId, newRating: newRating);
    } catch (e, st) {
      AppLogger.error('Error en AgencyService.updateAgencyRating',
          error: e, stackTrace: st, name: 'AgencyService');
      rethrow;
    }
  }

  Future<void> deleteAgency(String agencyId) async {
    try {
      await _repository.deleteAgency(agencyId);
    } catch (e, st) {
      AppLogger.error('Error en AgencyService.deleteAgency',
          error: e, stackTrace: st, name: 'AgencyService');
      rethrow;
    }
  }
}
