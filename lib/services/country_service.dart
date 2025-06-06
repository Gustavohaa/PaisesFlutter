import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/country.dart';

class CountryService {
  final http.Client client;

  
  CountryService({http.Client? client}) : client = client ?? http.Client();

  Future<List<Country>> fetchCountries() async {
    final response = await client.get(
      Uri.parse('https://restcountries.com/v3.1/all?fields=name,flags,capital,region,population'),
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      data.sort((a, b) => a['name']['common'].compareTo(b['name']['common']));
      return data.map((json) => Country.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar países: ${response.statusCode}');
    }
  }
}
