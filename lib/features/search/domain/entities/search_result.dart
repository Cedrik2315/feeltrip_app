class SearchResult {
  const SearchResult({
    required this.id,
    required this.title,
    required this.description,
    required this.rating,
    required this.imageUrl,
    required this.destination,
  });
  final String id;
  final String title;
  final String description;
  final double rating;
  final String imageUrl;
  final String destination;
}
