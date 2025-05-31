import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class Country {
  final String name;
  final String flag;
  final String capital;
  final int population;

  Country({
    required this.name,
    required this.flag,
    required this.capital,
    required this.population,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name']['common'],
      flag: json['flags']['png'],
      capital: (json['capital'] != null && json['capital'].isNotEmpty)
          ? json['capital'][0]
          : 'Sem capital',
      population: json['population'],
    );
  }
}

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

class CountryListPage extends StatefulWidget {
  const CountryListPage({super.key});

  @override
  State<CountryListPage> createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> {
  final ScrollController _scrollController = ScrollController();
  List<Country> _allCountries = [];
  List<Country> _visibleCountries = [];
  int _currentMax = 10;
  bool _isLoading = false;
  bool _hasError = false;

  Future<void> _fetchCountries() async {
    try {
      final response = await http.get(Uri.parse('https://restcountries.com/v3.1/all'));

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        data.sort((a, b) => a['name']['common'].compareTo(b['name']['common']));
        setState(() {
          _allCountries = data.map((json) => Country.fromJson(json)).toList();
          _visibleCountries = _allCountries.take(_currentMax).toList();
          _hasError = false;
        });
      } else {
        setState(() {
          _hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar países: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    }
  }

  void _loadMore() {
    if (_isLoading || _visibleCountries.length >= _allCountries.length) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _currentMax += 10;
        _visibleCountries = _allCountries.take(_currentMax).toList();
        _isLoading = false;
      });
    });
  }

  void _checkIfNeedsMoreData() {
    if (_scrollController.position.maxScrollExtent == 0 &&
        _visibleCountries.length < _allCountries.length) {
      _loadMore();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkIfNeedsMoreData();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCountries().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkIfNeedsMoreData();
      });
    });

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showDetails(Country country) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CountryDetailPage(country: country),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Países')),
      body: SafeArea(
        child: _hasError
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Erro ao carregar dados'),
                    ElevatedButton(
                      onPressed: _fetchCountries,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              )
            : _allCountries.isEmpty
                ? _buildProgressIndicator()
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _visibleCountries.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _visibleCountries.length) {
                        return _buildProgressIndicator();
                      }
                      final country = _visibleCountries[index];
                      return ListTile(
                        leading: Image.network(
                          country.flag,
                          width: 50,
                          height: 30,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.flag),
                        ),
                        title: Text(country.name),
                        subtitle: Text('Capital: ${country.capital}'),
                        onTap: () => _showDetails(country),
                      );
                    },
                  ),
      ),
    );
  }
}

class CountryDetailPage extends StatelessWidget {
  final Country country;

  const CountryDetailPage({super.key, required this.country});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(country.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              country.flag,
              height: 150,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.flag, size: 150),
            ),
            const SizedBox(height: 20),
            Text(
              'Capital: ${country.capital}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'População: ${country.population.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]}.',
                  )}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}