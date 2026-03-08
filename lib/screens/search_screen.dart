import 'package:flutter/material.dart';
import '../config/app_flags.dart';
import '../core/error_presenter.dart';
import '../models/trip_model.dart';
import '../repositories/app_data_repository.dart';
import '../services/observability_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final AppDataRepository _repository = AppDataRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Trip> _results = [];
  bool _isSearching = false;
  String? _errorMessage;
  String _selectedCategory = 'Todos';
  String _selectedDifficulty = 'Todos';
  double _maxPrice = 10000;

  final List<String> _categories = [
    'Todos',
    'Aventura',
    'Playa',
    'Cultural',
    'Bienestar',
    'Gastronomia',
  ];

  final List<String> _difficulties = ['Todos', 'Facil', 'Moderado', 'Dificil'];
  final List<String> _suggestions = [
    'Patagonia',
    'Bali',
    'Tromsø',
    'Machu Picchu',
    'Toscana',
    'París',
  ];

  @override
  void initState() {
    super.initState();
    _searchTrips();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchTrips() async {
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final result = await _repository.searchTrips(
        query: _searchController.text,
        category: _selectedCategory,
        difficulty: _selectedDifficulty,
        maxPrice: _maxPrice,
      );

      if (!mounted) return;
      final data = result.getOrElse(<Trip>[]);
      setState(() => _results = data);
      await ObservabilityService.logSearchExecuted(
        query: _searchController.text.trim(),
        resultsCount: data.length,
        category: _selectedCategory,
        difficulty: _selectedDifficulty,
        maxPrice: _maxPrice,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = ErrorPresenter.message(e));
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Viajes'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (showDemoIndicators && _repository.isMockMode)
              Container(
                width: double.infinity,
                color: Colors.amber.shade100,
                padding: const EdgeInsets.all(8),
                child: const Text(
                  'Modo demo activo: resultados simulados',
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Destino, pais, region...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sugerencias',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestions
                        .map(
                          (suggestion) => ActionChip(
                            label: Text(suggestion),
                            onPressed: () {
                              _searchController.text = suggestion;
                              _searchTrips();
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categoria',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories
                        .map((category) => FilterChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nivel de Dificultad',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _difficulties
                        .map((difficulty) => FilterChip(
                              label: Text(difficulty),
                              selected: _selectedDifficulty == difficulty,
                              onSelected: (_) {
                                setState(() {
                                  _selectedDifficulty = difficulty;
                                });
                              },
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Precio Maximo: \$${_maxPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value: _maxPrice,
                    min: 0,
                    max: 10000,
                    divisions: 20,
                    label: _maxPrice.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() {
                        _maxPrice = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _selectedCategory = 'Todos';
                          _selectedDifficulty = 'Todos';
                          _maxPrice = 10000;
                        });
                      },
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSearching ? null : _searchTrips,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: _isSearching
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Buscar'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resultados (${_results.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_errorMessage != null)
                    Text(_errorMessage!,
                        style: const TextStyle(color: Colors.red))
                  else if (_results.isEmpty)
                    const Text('No hay viajes que coincidan con tu busqueda')
                  else
                    ..._results.map(_buildResultCard),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Trip trip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.purple[100],
          ),
          child: const Icon(Icons.location_on, color: Colors.deepPurple),
        ),
        title: Text('${trip.destination}, ${trip.country}'),
        subtitle: Text(trip.category),
        trailing: Text(
          '\$${trip.price.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
            fontSize: 14,
          ),
        ),
        onTap: () async {
          await ObservabilityService.logTripOpened(
            tripId: trip.id,
            source: 'search_results',
          );
          if (!mounted) return;
          Navigator.pushNamed(
            context,
            '/trip-details',
            arguments: trip.id,
          );
        },
      ),
    );
  }
}
