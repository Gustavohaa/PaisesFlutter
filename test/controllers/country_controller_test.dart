import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:paises/controllers/country_controller.dart';
import 'package:paises/models/country.dart';
import 'package:paises/services/country_service.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../mocks/mock_test.mocks.dart'; 

void main() {
  test('Cenário 01 – Listagem bem-sucedida', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode([
          {
            'name': {'common': 'Brasil'},
            'flags': {'png': 'https://flagcdn.com/br.png'},
            'capital': ['Brasília'],
            'population': 211000000,
          },
          {
            'name': {'common': 'Argentina'},
            'flags': {'png': 'https://flagcdn.com/ar.png'},
            'capital': ['Buenos Aires'],
            'population': 45000000,
          },
        ]),
        200,
      );
    });

    final service = CountryService(client: mockClient);
    final controller = CountryController(service);

    final countries = await controller.getCountries();

    expect(countries, isNotEmpty);
    expect(countries[0].name, 'Argentina');
    expect(countries[0].capital, 'Buenos Aires');
    expect(countries[0].flag, 'https://flagcdn.com/ar.png');
    expect(countries[0].population, 45000000);
  });

  test('Cenário 02 – Erro na requisição de países', () async {
    final mockClient = MockClient((request) async {
      return http.Response('Erro interno', 500);
    });

    final service = CountryService(client: mockClient);
    final controller = CountryController(service);

    expect(() async => await controller.getCountries(), throwsException);
  });
  test('Cenário 03 – Busca de país por nome com resultado', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode([
          {
            'name': {'common': 'Brasil'},
            'flags': {'png': 'https://flagcdn.com/br.png'},
            'capital': ['Brasília'],
            'population': 211000000,
          },
          {
            'name': {'common': 'Argentina'},
            'flags': {'png': 'https://flagcdn.com/ar.png'},
            'capital': ['Buenos Aires'],
            'population': 45000000,
          },
        ]),
        200,
      );
    });

    final service = CountryService(client: mockClient);
    final controller = CountryController(service);

    final countries = await controller.getCountries();
    final brasil = countries.firstWhere(
      (c) => c.name == 'Brasil',
      orElse: () => throw Exception('País não encontrado'),
    );

    expect(brasil, isNotNull);
    expect(brasil.name, 'Brasil');
    expect(brasil.capital, 'Brasília');
    expect(brasil.population, 211000000);
    expect(brasil.flag, 'https://flagcdn.com/br.png');
  });

  test('Cenário 04 – Busca de país por nome com resultado vazio', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode([
          {
            'name': {'common': 'Brasil'},
            'flags': {'png': 'https://flagcdn.com/br.png'},
            'capital': ['Brasília'],
            'population': 211000000,
          },
        ]),
        200,
      );
    });

    final service = CountryService(client: mockClient);
    final controller = CountryController(service);

    final countries = await controller.getCountries();

    Country? paisDesconhecido;
    try {
      paisDesconhecido = countries.firstWhere((c) => c.name == 'Nárnia');
      fail('Era esperado que não encontrasse o país');
    } catch (e) {
      expect(e, isA<StateError>());
    }
  });

  test('Cenário 06 – Verificar se listarPaises foi chamado', () async {
    final mockService = MockCountryService();

    when(mockService.fetchCountries()).thenAnswer((_) async => []);

    final controller = CountryController(mockService);

    await controller.getCountries();

    verify(mockService.fetchCountries()).called(1);
  });
}
