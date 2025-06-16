import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:paises/controllers/country_controller.dart';
import 'dart:convert';

import 'package:paises/services/country_service.dart';
import 'package:paises/models/country.dart';

void main() {
  group('CountryService', () {
    test('fetchCountries retorna lista de países em caso de sucesso', () async {
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode([
          {
            'name': {'common': 'Brasil'},
            'flags': {'png': 'https://flagcdn.com/br.png'},
            'capital': ['Brasília'],
            'population': 211000000,
          },
        ]), 200);
      });

      final service = CountryService(client: mockClient);
      final countries = await service.fetchCountries();

      expect(countries, isNotEmpty);
      expect(countries.first, isA<Country>());
      expect(countries.first.name, 'Brasil');
      expect(countries.first.capital, 'Brasília');
      expect(countries.first.population, 211000000);
      expect(countries.first.flag, 'https://flagcdn.com/br.png');
    });

    test('fetchCountries lança exceção em caso de erro HTTP', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Erro interno', 500);
      });

      final service = CountryService(client: mockClient);

      expect(() async => await service.fetchCountries(), throwsException);
    });
  });

  test('Cenário 09 – Filtra países com população maior que 100M', () async {
  final mockClient = MockClient((request) async {
    return http.Response(jsonEncode([
      {
        'name': {'common': 'Brasil'},
        'population': 211000000,
        'flags': {'png': ''},
        'capital': ['Brasília']
      },
      {
        'name': {'common': 'Uruguai'},
        'population': 3500000,
        'flags': {'png': ''},
        'capital': ['Montevidéu']
      },
    ]), 200);
  });

  final service = CountryService(client: mockClient);
  final controller = CountryController(service);

  final countries = await controller.getCountries();
  final filtrados = countries.where((c) => c.population > 100000000).toList();

  expect(filtrados.length, 1);
  expect(filtrados.first.name, 'Brasil');
});
}
