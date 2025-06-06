import 'package:flutter/material.dart';
import 'pages/country_list_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lazy Loading de Países',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CountryListPage(),
    );
  }
}
