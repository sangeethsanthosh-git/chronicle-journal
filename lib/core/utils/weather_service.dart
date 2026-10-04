import 'package:dio/dio.dart';

class WeatherResult {
  final double temperature;
  final String summary;

  const WeatherResult({required this.temperature, required this.summary});
}

class WeatherService {
  final Dio _dio;

  WeatherService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ),
          );

  Future<WeatherResult?> fetchCurrentWeather(double lat, double lon) async {
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current': 'temperature_2m,weather_code',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final current = response.data['current'];
        final temp = (current['temperature_2m'] as num).toDouble();
        final code = (current['weather_code'] as num).toInt();
        final summary = _weatherCodeToSummary(code);

        return WeatherResult(temperature: temp, summary: summary);
      }
    } catch (_) {
      // Offline fallback: graceful degradation
      return null;
    }
    return null;
  }

  String _weatherCodeToSummary(int code) {
    if (code == 0) return 'Clear Sky ☀️';
    if (code == 1 || code == 2) return 'Partly Cloudy ⛅';
    if (code == 3) return 'Overcast ☁️';
    if (code >= 45 && code <= 48) return 'Foggy 🌫️';
    if (code >= 51 && code <= 55) return 'Drizzle 🌦️';
    if (code >= 61 && code <= 65) return 'Rain 🌧️';
    if (code >= 71 && code <= 77) return 'Snow ❄️';
    if (code >= 80 && code <= 82) return 'Rain Showers 🌧️';
    if (code >= 95 && code <= 99) return 'Thunderstorm ⛈️';
    return 'Mild Breeze 🍃';
  }
}
