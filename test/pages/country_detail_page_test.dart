import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paises/models/country.dart';
import 'package:paises/pages/country_detail_page.dart';

void main() {
  testWidgets(
    'Cenário 01 – Verificar se o nome do país é carregado no AppBar',
    (WidgetTester tester) async {
      final country = Country(
        name: 'Brasil',
        capital: 'Brasília',
        population: 211000000,
        flag: 'https://example.com/brasil.png',
      );

      await tester.pumpWidget(
        MaterialApp(home: CountryDetailPage(country: country)),
      );

      expect(find.text('Brasil'), findsOneWidget);
      expect(find.text('Capital: Brasília'), findsOneWidget);
      expect(find.text('População: 211.000.000'), findsOneWidget);
    },
  );

  testWidgets(
    'Cenário 03 – Verificar se o componente de imagem com a bandeira é carregado',
    (WidgetTester tester) async {
      final country = Country(
        name: 'Brasil',
        capital: 'Brasília',
        population: 211000000,
        flag: 'https://example.com/brasil.png',
      );

      await tester.pumpWidget(
        MaterialApp(home: CountryDetailPage(country: country)),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      expect(imageWidget.image, isA<NetworkImage>());
      expect(
        (imageWidget.image as NetworkImage).url,
        equals('https://example.com/brasil.png'),
      );
    },
  );
}
