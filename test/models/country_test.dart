import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:paises/controllers/country_controller.dart';
import 'package:paises/services/country_service.dart';

void main() {
    test('Cenário 05 – País com dados incompletos', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode([
          {
            'name': {'common': 'País X'},
            'flags': {},
            'capital': [],
            'population': 123456,
          },
        ]),
        200,
      );
    });

    final service = CountryService(client: mockClient);
    final controller = CountryController(service);

    final countries = await controller.getCountries();

    expect(countries, isNotEmpty);
    expect(countries.first.name, 'País X');
    expect(countries.first.capital, 'Sem capital');
    expect(countries.first.flag, isEmpty);
  });
}
