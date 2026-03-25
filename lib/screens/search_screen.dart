import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todos';
  String _selectedDifficulty = 'Todos';
  double _maxPrice = 10000;

  final List<String> _categories = [
    'Todos',
    'Aventura',
    'Playa',
    'Cultural',
    'Bienestar',
    'Gastronomía'
  ];

  final List<String> _difficulties = ['Todos', 'Fácil', 'Moderado', 'Difícil'];

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
            // Campo de búsqueda
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Destino, país, región...',
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

            // Categorías
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categoría',
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
                              onSelected: (selected) {
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

            // Dificultad
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
                              onSelected: (selected) {
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

            // Precio máximo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Precio Máximo: \$${_maxPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value: _maxPrice,
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

            // Botones de acción
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
                      onPressed: () {
                        // Realizar búsqueda
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Buscando viajes...'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: const Text('Buscar'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Resultados simulados
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resultados Populares',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildResultCard('Tromsø, Noruega', '\$1,290', 'Aventura'),
                  _buildResultCard('Toscana, Italia', '\$980', 'Gastronomía'),
                  _buildResultCard('Bali, Indonesia', '\$750', 'Bienestar'),
                  _buildResultCard('París, Francia', '\$850', 'Cultural'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String destination, String price, String category) {
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
        title: Text(destination),
        subtitle: Text(category),
        trailing: Text(
          price,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
