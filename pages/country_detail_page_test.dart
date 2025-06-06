import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:paises/models/country.dart';
import 'package:paises/pages/country_detail_page.dart';


void main() {
  testWidgets('Deve renderizar CountryDetailPage com os dados do país',
      (WidgetTester tester) async {
    final country = Country(
      name: 'Brasil',
      flag: 'https://flagcdn.com/br.png',
      capital: 'Brasília',
      population: 211000000,
    );

    await tester.pumpWidget(
      MaterialApp(home: CountryDetailPage(country: country)),
    );

    expect(find.text('Brasil'), findsOneWidget);
    expect(find.text('Capital: Brasília'), findsOneWidget);
    expect(find.textContaining('População'), findsOneWidget);
  });
}
