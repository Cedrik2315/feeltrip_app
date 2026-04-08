import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- MODELOS Y ENUMS ---

enum VivencialCategory { 
  todas, 
  agricola, 
  historica, 
  gastronica, 
  natural 
}

extension VivencialCategoryX on VivencialCategory {
  String get displayName => name[0].toUpperCase() + name.substring(1);
}

// --- PROVIDERS (Lógica de Estado) ---

/// Provider para el término de búsqueda de texto
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider para la categoría vivencial seleccionada
final selectedCategoryProvider = StateProvider<VivencialCategory>((ref) => VivencialCategory.todas);

/// Motor de búsqueda: Reacciona a cambios en texto y categoría
final searchResultsProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final category = ref.watch(selectedCategoryProvider);
  
  // Si no hay intención de búsqueda, devolvemos lista vacía
  if (query.isEmpty && category == VivencialCategory.todas) return [];

  // Debounce: Evita llamadas excesivas mientras el usuario escribe
  await Future.delayed(const Duration(milliseconds: 400));

  // Simulación de Base de Datos / API del Observatorio
  final mockDatabase = [
    'Ruta de la Palta (Agrícola)',
    'Petroglifos de San Pedro (Histórica)',
    'Vinos del Valle de Aconcagua (Gastronómica)',
    'Sendero La Campana (Natural)',
    'Feria de Quillota (Gastronómica)',
    'Antiguos Mayorazgos (Histórica)',
    'Huertos Orgánicos Limache (Agrícola)',
  ];

  // Lógica de filtrado combinado
  return mockDatabase.where((item) {
    final matchesQuery = item.toLowerCase().contains(query.toLowerCase());
    final matchesCategory = category == VivencialCategory.todas || 
                             item.toLowerCase().contains(category.displayName);
    return matchesQuery && matchesCategory;
  }).toList();
});

// --- UI (SearchScreen) ---

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchSubmit(String value) {
    ref.read(searchQueryProvider.notifier).state = value.trim();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final selectedCat = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Color papel FeelTrip
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: _buildSearchField(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildCategoryFilters(selectedCat),
        ),
      ),
      body: searchResults.when(
        data: (results) => results.isEmpty 
            ? _buildEmptyState() 
            : _buildResultsList(results),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.teal, strokeWidth: 2),
        ),
        error: (err, stack) => Center(
          child: Text('Error en la expedición: $err', 
            style: const TextStyle(fontFamily: 'serif', fontStyle: FontStyle.italic)),
        ),
      ),
    );
  }

  // Widget: Buscador Minimalista
  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        onSubmitted: _onSearchSubmit,
        onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
        decoration: InputDecoration(
          hintText: 'Explora Quillota o Limache...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          prefixIcon: const Icon(Icons.search, color: Colors.teal),
          suffixIcon: _controller.text.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.close, size: 18), 
                onPressed: () {
                  _controller.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                })
            : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // Widget: Selector de Categorías (Chips)
  Widget _buildCategoryFilters(VivencialCategory selected) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: VivencialCategory.values.length,
        itemBuilder: (context, index) {
          final cat = VivencialCategory.values[index];
          final isActive = selected == cat;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat.displayName.toUpperCase()),
              selected: isActive,
              onSelected: (val) {
                if (val) ref.read(selectedCategoryProvider.notifier).state = cat;
              },
              labelStyle: TextStyle(
                fontSize: 10,
                letterSpacing: 1,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.white : Colors.teal[800],
              ),
              selectedColor: Colors.teal[800],
              backgroundColor: Colors.teal.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(
                color: isActive ? Colors.transparent : Colors.teal.withValues(alpha: 0.2),
                width: 0.5,
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  // Widget: Resultados Estilo Guía de Campo
  Widget _buildResultsList(List<String> results) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            title: Text(
              results[index],
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1712),
              ),
            ),
            subtitle: const Text(
              'EXPEDICIÓN DISPONIBLE • QUILLOTA',
              style: TextStyle(fontSize: 10, letterSpacing: 1, color: Colors.grey),
            ),
            trailing: const Icon(Icons.arrow_outward, size: 16, color: Colors.teal),
            onTap: () {
              // Navegación al detalle del destino
            },
          ),
        );
      },
    );
  }

  // Widget: Estado Inicial / Vacío
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore_outlined, size: 60, color: Colors.teal.withValues(alpha: 0.2)),
          const SizedBox(height: 20),
          const Text(
            'DESCUBRE TU PRÓXIMA RUTA',
            style: TextStyle(
              fontSize: 12, 
              letterSpacing: 2, 
              fontWeight: FontWeight.bold, 
              color: Colors.grey
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Busca por nombre o selecciona una categoría\npara ver qué experiencias te rodean.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}