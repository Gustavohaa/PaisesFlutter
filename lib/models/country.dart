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
    flag: (json['flags'] != null && json['flags']['png'] != null)
        ? json['flags']['png']
        : '', 
    capital: (json['capital'] != null && json['capital'].isNotEmpty)
        ? json['capital'][0]
        : 'Sem capital',
    population: json['population'] ?? 0,
  );
}
}
