import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  // OpenWeatherMap API key
  final String apiKey =
      '57ed8338202e762c192c75328f14c5b0'; // Replace with your OpenWeatherMap API key

  // Base URL for fetching weather data
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // Base URL for fetching air pollution data
  final String airPollutionUrl =
      'https://api.openweathermap.org/data/2.5/air_pollution';

  /// Fetches weather data for a given city name.
  Future<Weather> getWeatherByCity(String city) async {
    // Fetch weather data from OpenWeatherMap API
    final weatherResponse = await http.get(
      Uri.parse('$baseUrl?q=$city&units=metric&appid=$apiKey'),
    );

    if (weatherResponse.statusCode == 200) {
      final weatherData = json.decode(weatherResponse.body);

      // Extract latitude and longitude from weather data
      final lat = weatherData['coord']['lat'];
      final lon = weatherData['coord']['lon'];

      // Fetch air quality data based on coordinates
      final aqiResponse = await http.get(
        Uri.parse('$airPollutionUrl?lat=$lat&lon=$lon&appid=$apiKey'),
      );

      if (aqiResponse.statusCode == 200) {
        final aqiData = json.decode(aqiResponse.body);
        final aqi = aqiData['list'][0]['main']['aqi'];
        final visibility =
            weatherData['visibility'] ?? 10000; // Default visibility

        // Create and return a Weather object with combined weather and AQI data
        return Weather.fromJson({
          ...weatherData,
          'aqi': aqi,
          'visibility': visibility,
        });
      } else {
        throw Exception(
            'Failed to fetch AQI data'); // Error handling for AQI fetch
      }
    } else {
      throw Exception(
          'Failed to load weather data'); // Error handling for weather fetch
    }
  }

  /// Fetches weather data for a given latitude and longitude.
  Future<Weather> getWeatherByLocation(double lat, double lon) async {
    // Fetch weather data from OpenWeatherMap API using coordinates
    final weatherResponse = await http.get(
      Uri.parse('$baseUrl?lat=$lat&lon=$lon&units=metric&appid=$apiKey'),
    );

    if (weatherResponse.statusCode == 200) {
      final weatherData = json.decode(weatherResponse.body);

      // Fetch air quality data based on coordinates
      final aqiResponse = await http.get(
        Uri.parse('$airPollutionUrl?lat=$lat&lon=$lon&appid=$apiKey'),
      );

      if (aqiResponse.statusCode == 200) {
        final aqiData = json.decode(aqiResponse.body);
        final aqi = aqiData['list'][0]['main']['aqi'];
        final visibility =
            weatherData['visibility'] ?? 10000; // Default visibility

        // Create and return a Weather object with combined weather and AQI data
        return Weather.fromJson({
          ...weatherData,
          'aqi': aqi,
          'visibility': visibility,
        });
      } else {
        throw Exception(
            'Failed to fetch AQI data'); // Error handling for AQI fetch
      }
    } else {
      throw Exception(
          'Failed to load weather data'); // Error handling for weather fetch
    }
  }
}
