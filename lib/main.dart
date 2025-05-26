import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class Country {
  final String name;
  final String flag;

  Country({
    required this.name,
    required this.flag,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name']['common'],
      flag: json['flags']['png'],
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Country> countries = [];
  bool isLoading = false;
  int page = 1;

  @override
  void initState() {
    super.initState();
    loadCountries();
  }

  Future<void> loadCountries() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
        Uri.parse('https://restcountries.com/v3.1/all?fields=name,flags'));

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      List<Country> loadedCountries = [];
      for (var countryJson in jsonData) {
        loadedCountries.add(Country.fromJson(countryJson));
      }

      setState(() {
        countries.addAll(loadedCountries.take(10 * page)); 
        page++;
        isLoading = false;
      });
    } else {
      throw Exception('Falha ao carregar países');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lista de Países'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: countries.length + 1, 
                itemBuilder: (context, index) {
                  if (index == countries.length) {
                    return Center(
                      child: isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: loadCountries,
                              child: Text('Carregar mais países'),
                            ),
                    );
                  }
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: Image.network(countries[index].flag, width: 50),
                      title: Text(countries[index].name),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
