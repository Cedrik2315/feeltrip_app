import 'package:flutter/material.dart';
import '../../services/destination_service.dart';

class WeatherWidget extends StatelessWidget {
  final String city;

  const WeatherWidget({
    super.key,
    required this.city,
  });

  IconData _getWeatherIcon(String iconCode) {
    final code = iconCode.substring(0, 2);
    return switch (code) {
      '01' => Icons.wb_sunny,
      '02' || '03' => Icons.cloud,
      '09' || '10' || '11' => Icons.umbrella,
      '13' => Icons.ac_unit,
      '50' => Icons.water_drop,
      _ => Icons.cloud_off,
    };
  }

  String _capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FutureBuilder<WeatherInfo?>(
        future: DestinationService.getWeather(city),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text('?',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            );
          }

          final weather = snapshot.data!;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getWeatherIcon(weather.icon),
                size: 16,
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 4),
              Text(
                '${weather.temperatureC.round()}°C',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                ' ${_capitalize(weather.description)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                ' $city',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
