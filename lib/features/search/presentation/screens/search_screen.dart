import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:feeltrip_app/services/media_service.dart';
import '../providers/search_notifier.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Buscar por título o destino...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          onChanged: (value) {
            // Buscamos en la colección de historias (o experiencias)
            ref.read(searchNotifierProvider.notifier).search(value, collection: 'stories');
          },
        ),
        actions: [
          if (searchState.results.isNotEmpty || searchState.isLoading)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => ref.read(searchNotifierProvider.notifier).clearSearch(),
            ),
        ],
      ),
      body: _buildBody(searchState),
    );
  }

  Widget _buildBody(SearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text(state.error!, style: const TextStyle(color: Colors.red)));
    }

    if (state.results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Escribe algo para empezar a explorar', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final item = state.results[index];
        return ListTile(
          leading: item['imageUrl'] != null 
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  MediaService.getOptimizedUrl(item['imageUrl'] as String, width: 150), 
                  width: 50, 
                  height: 50, 
                  fit: BoxFit.cover),
              )
            : const Icon(Icons.map),
          title: Text((item['title'] as String?) ?? 'Sin título'),
          subtitle: Text((item['destination'] as String?) ?? (item['emotion'] as String?) ?? ''),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Lógica de navegación al detalle
          },
        );
      },
    );
  }
}