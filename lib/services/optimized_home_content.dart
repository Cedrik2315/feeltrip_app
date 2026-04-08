import 'package:flutter/material.dart';
import 'package:feeltrip_app/services/media_service.dart';

/// Widget optimizado para la Home que utiliza Slivers para un scroll fluido
/// y RepaintBoundary para evitar repintados innecesarios en elementos pesados.
class OptimizedHomeContent extends StatelessWidget {

  const OptimizedHomeContent({super.key, required this.featuredItems});
  final List<Map<String, dynamic>> featuredItems;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverAppBar(
          floating: true,
          snap: true,
          title: Text('FeelTrip'),
          expandedHeight: 60,
        ),
        
        // Usamos RepaintBoundary en secciones que no cambian frecuentemente
        // para aislar el repintado de la lista principal.
        SliverToBoxAdapter(
          child: RepaintBoundary(
            child: _buildHeroSection(),
          ),
        ),

        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Experiencias Destacadas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // SliverList es mucho más eficiente que un ListView tradicional
        // ya que recicla los elementos de forma más agresiva en el viewport.
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = featuredItems[index];
              return RepaintBoundary(
                child: _HomeCard(item: item),
              );
            },
            childCount: featuredItems.length,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.blue]),
      ),
      child: const Center(
        child: Text('✨ Tu próxima aventura comienza aquí', 
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: item['imageUrl'] != null 
            ? Image.network(MediaService.getOptimizedUrl(item['imageUrl'] as String, width: 100))
            : const Icon(Icons.image),
        title: Text((item['title'] as String?) ?? 'Sin título'),
        subtitle: Text((item['destination'] as String?) ?? ''),
      ),
    );
  }
}
