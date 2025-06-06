import '../models/country.dart';
import '../services/country_service.dart';

class CountryController {
  final CountryService _service;

  CountryController(this._service);

  Future<List<Country>> getCountries() async {
    return await _service.fetchCountries();
  }
}
