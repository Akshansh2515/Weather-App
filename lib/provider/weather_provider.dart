import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather.dart';
import '../services/weather_services.dart';

class WeatherProvider with ChangeNotifier {
  // Private variables to hold weather data and state information
  Weather? _searchedWeather; // Weather data for the searched city
  Weather? _currentLocationWeather; // Weather data for the current location
  bool _isLoading = false; // Loading state flag
  String _error = ''; // Error message for failed requests

  // Public getters for the private variables
  Weather? get searchedWeather =>
      _searchedWeather; // Get the weather data for the searched city

  Weather? get currentLocationWeather =>
      _currentLocationWeather; // Get the weather data for the current location

  bool get isLoading =>
      _isLoading; // Check if the provider is currently loading data

  String get error => _error; // Get the error message, if any

  final WeatherService _weatherService =
      WeatherService(); // Service to fetch weather data

  // List to store recent cities for autocomplete suggestions
  final List<String> _recentCities = [];
  List<String> get recentCities =>
      _recentCities; // Get the list of recent cities

  /// Fetches weather data for a specific city by name.
  Future<void> fetchWeatherByCity(String city) async {
    _isLoading = true; // Set loading state to true
    _error = ''; // Clear any previous error message
    notifyListeners(); // Notify listeners of the state change

    try {
      _searchedWeather = await _weatherService.getWeatherByCity(city);
      // Add the city to the recent cities list if it is not already present
      if (!_recentCities.contains(city)) {
        _recentCities.add(city);
      }
      _error = ''; // Clear any previous error message
    } catch (e) {
      _error =
          'Failed to fetch weather data. Please try again.'; // Set the error message for failed requests
      _searchedWeather = null; // Clear the searched weather data on error
    }

    _isLoading = false; // Set loading state to false
    notifyListeners(); // Notify listeners of the state change
  }

  /// Fetches weather data for the current location of the device.
  Future<void> fetchCurrentLocationWeather() async {
    _isLoading = true; // Set loading state to true
    _error = ''; // Clear any previous error message
    notifyListeners(); // Notify listeners of the state change

    try {
      // Get the current position of the device
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      // Fetch weather data for the current position
      _currentLocationWeather = await _weatherService.getWeatherByLocation(
          position.latitude, position.longitude);
      _error = ''; // Clear any previous error message
    } catch (e) {
      _error =
          'Failed to fetch current location weather. Please try again.'; // Set the error message for failed requests
      _currentLocationWeather =
          null; // Clear the current location weather data on error
    }

    _isLoading = false; // Set loading state to false
    notifyListeners(); // Notify listeners of the state change
  }

  /// Fetches weather data based on the searched weather or current location.
  Future<void> fetchWeatherData() async {
    if (_searchedWeather != null) {
      await fetchWeatherByCity(
          _searchedWeather!.cityName); // Fetch weather for the searched city
    } else {
      await fetchCurrentLocationWeather(); // Fetch weather for the current location
    }
  }

  /// Gets the current date and time.
  DateTime getCurrentDateTime() {
    return DateTime.now(); // Return the current date and time
  }

  /// Fetches city suggestions based on the query.
  Future<List<String>> fetchCitySuggestions(String query) async {
    // Return recent cities that match the query
    return _recentCities
        .where((city) => city
            .toLowerCase()
            .contains(query.toLowerCase())) // Filter cities based on the query
        .toList(); // Convert the filtered cities to a list
  }
}
