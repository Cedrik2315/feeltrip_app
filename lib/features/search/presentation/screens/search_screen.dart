import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/search_notifier.dart';
import '../../../../core/router/route_names.dart';
import 'package:feeltrip_app/widgets/destination_card.dart';

// 1. Cambiamos a ConsumerStatefulWidget para persistir el controlador
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  // 2. Definimos el controlador aquí
  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController();
  }

  @override
  void dispose() {
    // 3. ¡Súper importante! Liberar la memoria al cerrar la pantalla
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 4. Simplificamos la lectura del estado
    final searchState = ref.watch(searchNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Experiencias'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.home),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: 'Buscar viajes vivenciales...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _queryController.clear(),
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  ref.read(searchNotifierProvider.notifier).searchExperiences(query);
                }
              },
            ),
          ),
          Expanded(
            child: searchState.when(
              data: (results) => results.isEmpty
                  ? const Center(child: Text('No se encontraron resultados'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return DestinationCard(
                          title: result.title,
                          destination: result.destination,
                          imageUrl: result.imageUrl,
                          onTap: () => context.go('${RouteNames.tripDetail}/${result.id}'),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
