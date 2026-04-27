import 'google_places_service.dart';
import 'institution_api_service.dart';

class InstitutionRepository {
  InstitutionRepository();

  Future<List<PlaceSummary>> getAnkaraVets({
    int radiusMeters = 35000,
    bool forceRefresh = false,
  }) async {
    return InstitutionApiService.fetchClinics();
  }

  Future<List<PlaceSummary>> getAnkaraShelters({
    int radiusMeters = 35000,
    bool forceRefresh = false,
  }) async {
    return InstitutionApiService.fetchShelters();
  }
}
