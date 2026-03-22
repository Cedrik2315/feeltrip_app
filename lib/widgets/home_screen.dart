import 'package:feeltrip_app/presentation/providers/search_provider.dart';
import 'package:feeltrip_app/widgets/destination_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For demonstration, we use the search provider to get some trip data.
    // In a real app, you'd have a dedicated provider for featured trips.
    final tripsAsync = ref.watch(debouncedSearchProvider);

    // Trigger an initial search to populate the list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(searchQueryProvider).isEmpty) {
        ref.read(searchQueryProvider.notifier).state =
            'a'; // search for trips containing 'a'
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('FeelTrip'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/search'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: tripsAsync.when(
              data: (trips) {
                if (trips.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text('No se encontraron viajes.')),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final trip = trips[index];
                      return DestinationCard(
                        title: trip.title,
                        destination: trip.destination,
                        imageUrl:
                            trip.images.isNotEmpty ? trip.images.first : null,
                        onTap: () =>
                            context.go('${RouteNames.tripDetail}/${trip.id}'),
                      );
                    },
                    childCount: trips.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverToBoxAdapter(
                child: Center(child: Text('Error: $error')),
              ),
            ),
          ),
        ],
      ),
      // In a real app, this BottomNavigationBar would be part of a ShellRoute
      // to persist across screens like Home, Search, Profile, etc.
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              context.go('/search');
            case 2:
              context.go('/diary');
            case 3:
              context.go('/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Diario'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Viajes que Transforman',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Descubre tu próximo destino emocional.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.go('/quiz'),
            icon: const Icon(Icons.psychology),
            label: const Text('Descubre tu tipo de viajero'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
