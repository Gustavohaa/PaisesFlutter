import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:paises/pages/country_list_page.dart';

void main() {
  testWidgets('Deve renderizar CountryListPage', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CountryListPage()));
    expect(find.text('Lista de Países'), findsOneWidget);
  });
}
