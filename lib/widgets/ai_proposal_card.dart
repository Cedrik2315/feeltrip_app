import 'package:flutter/material.dart';
import 'package:feeltrip_app/models/travel_agency_model.dart';
import 'package:feeltrip_app/services/destination_service.dart';

class AiProposalCard extends StatefulWidget {
  const AiProposalCard({
    super.key,
    required this.agency,
    required this.moodEmoji,
    required this.moodBadge,
    this.userCurrency = 'USD',
    this.onAdditionalTap,
  });

  final TravelAgency agency;
  final String moodEmoji;
  final String moodBadge;
  final String userCurrency;
  final VoidCallback? onAdditionalTap;

  @override
  State<AiProposalCard> createState() => _AiProposalCardState();
}

class _AiProposalCardState extends State<AiProposalCard> {
  List<String> photos = [];
  Map<String, dynamic> weather = {};
  Map<String, dynamic> countryInfo = {};
  List<String> financialLabels = [];
  bool _showLogistica = false;
  bool _isLoading = true;
  String _backgroundImage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final city = widget.agency.city.isNotEmpty
          ? widget.agency.city
          : widget.agency.country;
      final destinationPhotos =
          await DestinationService.getDestinationPhotos(city);
      final destWeather = await DestinationService.getWeather(
          widget.agency.latitude, widget.agency.longitude);
      final destCountry =
          await DestinationService.getCountryInfo(widget.agency.country);

      final List<Map<String, dynamic>> priceSamples = [
        {'label': 'Café', 'amount': 2.50, 'base': 'EUR'},
        {'label': 'Hotel/noche', 'amount': 80.0, 'base': 'EUR'},
      ];

      final List<String> financials = [];
      final currencyCode = (destCountry['currencies'] as Map?)?.keys.first;

      if (currencyCode != null && currencyCode != widget.userCurrency) {
        for (final price in priceSamples) {
          final converted = await DestinationService.convertCurrency(
              price['base'] as String,
              widget.userCurrency,
              price['amount'] as double);
          financials.add(
              '${price['label']}: ${(price['amount'] as double).toStringAsFixed(2)} ${price['base']} ≈ ${converted.toStringAsFixed(2)} ${widget.userCurrency}');
        }
      }

      setState(() {
        photos = destinationPhotos;
        weather = destWeather ?? {};
        countryInfo = destCountry;
        financialLabels = financials;
        _backgroundImage =
            photos.isNotEmpty ? photos.first : widget.agency.logo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getWeatherIcon(String? iconCode) {
    if (iconCode == null) return '☀️';
    return switch (iconCode[0]) {
      '01' => '☀️',
      '02' || '03' || '04' => '☁️',
      '09' || '10' => '🌧️',
      '11' => '⛈️',
      '13' => '❄️',
      '50' => '🌫️',
      _ => '🌤️',
    };
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight = _showLogistica ? 320 : 240;

    // Safely parse country info
    final flagUrl = (countryInfo['flags'] as Map?)?['png'] as String?;
    final capital = (countryInfo['capital'] as List?)?.first as String? ?? '?';
    final currency = (countryInfo['currencies'] as Map?)?.keys.first ?? '?';
    final population = (countryInfo['population'] as num?) ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Hero(
        tag: 'ai-proposal-${widget.agency.id}',
        child: GestureDetector(
          onTap: () {
            if (_showLogistica) {
              widget.onAdditionalTap?.call();
            } else {
              setState(() => _showLogistica = true);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: cardHeight,
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background image
                        Image.network(
                          _backgroundImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.deepPurple, Colors.indigo],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(
                              Icons.travel_explore,
                              size: 100,
                              color: Colors.white70,
                            ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.7, 1.0],
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.4),
                                Colors.black87,
                              ],
                            ),
                          ),
                        ),
                        // Mood Badge
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.amberAccent),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(widget.moodEmoji,
                                    style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 6),
                                Text(
                                  widget.moodBadge,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Weather Top-right
                        if (weather.isNotEmpty) ...[
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _getWeatherIcon(weather['icon'] as String?),
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  Text(
                                    '${(weather['temp'] as num?)?.toStringAsFixed(0) ?? '?'}°',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                            color: Colors.black54)
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        // Content bottom-left
                        Positioned(
                          bottom: _showLogistica ? 100 : 20,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.agency.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 4,
                                        color: Colors.black87),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 32,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.agency.specialties.length
                                      .clamp(0, 3),
                                  itemBuilder: (context, index) {
                                    final specialty =
                                        widget.agency.specialties[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple
                                              .withValues(alpha: 0.9),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          specialty,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Financial Context chips
                        if (financialLabels.isNotEmpty)
                          ...financialLabels
                              .asMap()
                              .entries
                              .take(2)
                              .map((e) => Positioned(
                                    bottom: 60,
                                    left: 16 + (e.key * 80),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.green.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        e.value,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        // Logística section
                        if (_showLogistica && countryInfo.isNotEmpty)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.black87,
                                border: Border(
                                    top: BorderSide(color: Colors.white24)),
                              ),
                              child: Row(children: [
                                if (flagUrl != null)
                                  Image.network(
                                    flagUrl,
                                    width: 32,
                                    height: 24,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.flag,
                                        color: Colors.white70),
                                  ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$capital • $currency',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        'Población: ${(population / 1000000).toStringAsFixed(0)}M hab.',
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white),
                                  onPressed: () =>
                                      setState(() => _showLogistica = false),
                                ),
                              ]),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
