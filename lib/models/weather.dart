class Weather {
  final String cityName;
  final double temperature;
  final double minTemp; // Minimum temperature for the day
  final double maxTemp; // Maximum temperature for the day
  final double feelsLike; // Temperature as it feels
  final String condition;
  final String icon;
  final int humidity;
  final double windSpeed;
  final int sunrise;
  final int sunset;
  final int timestamp;
  final int clouds;
  final int aqi; // Air Quality Index
  final int visibility;

  // Constructor to initialize Weather object
  Weather({
    required this.cityName,
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
    required this.feelsLike,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.sunrise,
    required this.sunset,
    required this.timestamp,
    required this.clouds,
    required this.aqi,
    required this.visibility,
  });

  // Create a Weather object from JSON data
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'] ?? 'Unknown',
      temperature: (json['main']['temp'] as num?)?.toDouble() ?? 0.0,
      minTemp: (json['main']['temp_min'] as num?)?.toDouble() ?? 0.0,
      maxTemp: (json['main']['temp_max'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['main']['feels_like'] as num?)?.toDouble() ?? 0.0,
      condition: json['weather']?[0]?['main'] ?? 'Unknown',
      icon: json['weather']?[0]?['icon'] ?? '01d',
      humidity: json['main']?['humidity'] as int? ?? 0,
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      sunrise: json['sys']?['sunrise'] as int? ?? 0,
      sunset: json['sys']?['sunset'] as int? ?? 0,
      timestamp: json['dt'] as int? ?? 0,
      clouds: json['clouds']?['all'] as int? ?? 0,
      aqi: json['aqi'] ?? 1,
      visibility: json['visibility'] ?? 10000,
    );
  }

  // Check if the current time is during the day
  bool isDayTime() {
    return timestamp >= sunrise && timestamp < sunset;
  }

  // Get the air quality index description
  String getAqiDescription() {
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Fair';
      case 3:
        return 'Moderate';
      case 4:
        return 'Poor';
      case 5:
        return 'Very Poor';
      default:
        return 'Unknown';
    }
  }

  // Get the URL for the weather icon
  String getWeatherIconUrl() {
    return 'https://openweathermap.org/img/wn/$icon.png';
  }
}

extension DateTimeFormat on int {
  DateTime toDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(this * 1000);
  }
}

extension DateTimeFormatExtension on DateTime {
  String format(String format) {
    final hours = hour.toString().padLeft(2, '0');
    final minutes = minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  String getDayOfWeek() {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return days[weekday % 7];
  }
}
