import 'package:flutter/material.dart';
import '../controllers/country_controller.dart';
import '../models/country.dart';
import '../services/country_service.dart';
import 'country_detail_page.dart';

class CountryListPage extends StatefulWidget {
  const CountryListPage({super.key});

  @override
  State<CountryListPage> createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> {
  final _scrollController = ScrollController();
  final _controller = CountryController(CountryService());

  List<Country> _allCountries = [];
  List<Country> _visibleCountries = [];
  int _currentMax = 10;
  bool _isLoading = false;
  bool _hasError = false;

  Future<void> _loadCountries() async {
    try {
      final countries = await _controller.getCountries();
      setState(() {
        _allCountries = countries;
        _visibleCountries = countries.take(_currentMax).toList();
        _hasError = false;
      });
    } catch (e) {
      setState(() => _hasError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
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
  if (!_scrollController.hasClients) return; // Adicionado!

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
    _loadCountries().then((_) {
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

  Widget _buildProgressIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  void _showDetails(Country country) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CountryDetailPage(country: country),
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
                      onPressed: _loadCountries,
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
