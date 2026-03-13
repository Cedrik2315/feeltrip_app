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

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final AppDataRepository _repository = AppDataRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Trip> _results = [];
  bool _isSearching = false;
  String? _errorMessage;
  String _selectedCategory = 'Todos';
  String _selectedDifficulty = 'Todos';
  double _maxPrice = 10000;
  AnimationController? _shimmerController;

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
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _searchTrips();
  }

  @override
  @override
  void dispose() {
    _shimmerController?.dispose();
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
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Destino, país, región...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    filled: false,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.deepPurple),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : const SizedBox(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories
                          .map((category) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedCategory == category
                                        ? Colors.deepPurple
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: _selectedCategory == category
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _difficulties
                          .map((difficulty) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDifficulty = difficulty;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedDifficulty == difficulty
                                        ? Colors.deepPurple
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    difficulty,
                                    style: TextStyle(
                                      color: _selectedDifficulty == difficulty
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
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
                  else if (_isSearching)
                    _buildShimmerGrid()
                  else if (_results.isEmpty)
                    _buildEmptyState()
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _results.length,
                      itemBuilder: (context, index) =>
                          _buildTripCard(_results[index]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    final Color categoryColor = _getCategoryColor(trip.category);
    // const double rating = 4.5; // hardcoded stars
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple.withValues(alpha: 0.8),
                          Colors.deepPurple
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.landscape,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${trip.destination}, ${trip.country}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${trip.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trip.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                    5,
                    (index) => Icon(
                          index < 4 ? Icons.star : Icons.star_border,
                          color: Colors.amber[400],
                          size: 16,
                        )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    return switch (category) {
      'Aventura' => Colors.orange,
      'Playa' => Colors.blue,
      'Cultural' => Colors.green,
      'Bienestar' => Colors.purple,
      'Gastronomia' => Colors.red,
      _ => Colors.grey,
    };
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => AnimatedBuilder(
        animation: _shimmerController!,
        builder: (context, child) {
          final shimmerPosition = _shimmerController!.value;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.grey[300]!,
                  Colors.grey[100]!.withValues(alpha: 0.6),
                  Colors.grey[300]!,
                ],
                stops: [
                  shimmerPosition - 0.4,
                  shimmerPosition,
                  shimmerPosition + 0.4
                ],
                begin: const Alignment(-1.0, 0.0),
                end: const Alignment(1.0, 0.0),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final String query = _searchController.text.trim();
    return Column(
      children: [
        Icon(
          Icons.search,
          size: 80,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          'No encontramos resultados para "${query.isEmpty ? 'tu búsqueda' : query}"',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Prueba con estas búsquedas populares',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestions
              .map((suggestion) => ActionChip(
                    label: Text(suggestion),
                    onPressed: () {
                      _searchController.text = suggestion;
                      _searchTrips();
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }
}
