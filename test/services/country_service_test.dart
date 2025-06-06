import 'package:flutter_test/flutter_test.dart';
import 'package:paises/services/country_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

void main() {
  test('Deve retornar uma lista de países do serviço', () async {
    final service = CountryService(
      client: MockClient((request) async {
        return http.Response(jsonEncode([
          {
            'name': {'common': 'Brasil'},
            'flags': {'png': 'https://flagcdn.com/br.png'},
            'capital': ['Brasília'],
            'population': 211000000,
          }
        ]), 200);
      }),
    );

    final countries = await service.fetchCountries();
    expect(countries.length, 1);
    expect(countries[0].name, 'Brasil');
  });
}
