import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paises/models/country.dart';
import 'package:paises/pages/country_detail_page.dart';

class FakeCountryService {
  Future<List<Country>> getCountries() async {
    return [
      Country(
        name: 'Brasil',
        capital: 'Brasília',
        population: 211000000,
        flag: 'https://example.com/brasil.png',
      ),
    ];
  }
}

void main() {
  testWidgets('Cenário 02 – Clicar em um país abre a página de detalhes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CountryDetailPage(
                      country: Country(
                        name: 'Brasil',
                        capital: 'Brasília',
                        population: 211000000,
                        flag: 'https://example.com/brasil.png',
                      ),
                    ),
                  ),
                ),
                child: const Text('Brasil'),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Brasil'), findsOneWidget);
    await tester.tap(find.text('Brasil'));
    await tester.pumpAndSettle();

    expect(find.text('Capital: Brasília'), findsOneWidget);
  });
}
