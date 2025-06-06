import 'package:flutter_test/flutter_test.dart';
import 'package:paises/models/country.dart';

void main() {
  test('Deve criar Country a partir do JSON', () {
    final json = {
      'name': {'common': 'Brasil'},
      'flags': {'png': 'https://flagcdn.com/br.png'},
      'capital': ['Brasília'],
      'population': 211000000,
    };

    final country = Country.fromJson(json);

    expect(country.name, 'Brasil');
    expect(country.flag, 'https://flagcdn.com/br.png');
    expect(country.capital, 'Brasília');
    expect(country.population, 211000000);
  });
}
