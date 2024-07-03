import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather/models/weather.dart';
import '../provider/weather_provider.dart';

class WeatherDetailsScreen extends StatelessWidget {
  const WeatherDetailsScreen({super.key});

  // Format the temperature to a string with °C symbol
  String getFormattedTemperature(double temp) {
    return '${temp.toStringAsFixed(0)}°C';
  }

  // Format a DateTime object to a string in HH:mm format
  String getFormattedTime(DateTime date) {
    final String hours = date.hour.toString().padLeft(2, '0');
    final String minutes = date.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Main layout of the screen
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          final weather = weatherProvider.searchedWeather ??
              weatherProvider.currentLocationWeather;

          if (weather != null) {
            final weatherDate = weather.timestamp.toDateTime();
            final dayOfWeek = weatherDate.getDayOfWeek();
            final time = weatherDate.format('HH:mm');

            return Stack(
              children: [
                // Background image based on day or night
                Image.asset(
                  weather.isDayTime()
                      ? 'assets/day_background.png'
                      : 'assets/night_background.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 80.0),
                      child: Column(
                        children: [
                          // City name display
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                weather.cityName,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Time and day of the week display
                          Text(
                            '$time, $dayOfWeek',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 20),
                          // Temperature and min/max temperature display
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                getFormattedTemperature(weather.temperature),
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(color: Colors.white),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getFormattedTemperature(weather.minTemp),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Colors.white, fontSize: 14),
                                  ),
                                  Text(
                                    'Min Temp',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Colors.white, fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    getFormattedTemperature(weather.maxTemp),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Colors.white, fontSize: 14),
                                  ),
                                  Text(
                                    'Max Temp',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Weather condition and AQI display
                          Text(
                            weather.condition,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'AQI: ${weather.aqi} (${weather.getAqiDescription()})',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 1),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 60),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 15,
                            childAspectRatio: 2.0,
                          ),
                          children: [
                            _buildDetail(
                              context,
                              '${weather.humidity}%',
                              'Humidity',
                              Icons.water_drop,
                            ),
                            _buildDetail(
                              context,
                              '${weather.visibility / 1000} km',
                              'Visibility',
                              Icons.visibility,
                            ),
                            _buildDetail(
                              context,
                              '${weather.clouds}%',
                              'Clouds',
                              Icons.cloud,
                            ),
                            _buildDetail(
                              context,
                              '${weather.windSpeed} m/s',
                              'Wind Speed',
                              Icons.air,
                            ),
                            _buildDetail(
                              context,
                              weather.sunrise.toDateTime().format('HH:mm'),
                              'Sunrise',
                              Icons.wb_sunny,
                            ),
                            _buildDetail(
                              context,
                              weather.sunset.toDateTime().format('HH:mm'),
                              'Sunset',
                              Icons.nights_stay,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0, right: 20.0),
                    child: IconButton(
                      icon: const Icon(Icons.refresh),
                      color: Colors.white,
                      onPressed: () {
                        final weatherProvider = context.read<WeatherProvider>();
                        weatherProvider.fetchWeatherData();
                      },
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  // Build a detail widget for the grid
  Widget _buildDetail(
      BuildContext context, String value, String label, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(color: Colors.white),
        ),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Colors.white),
        ),
      ],
    );
  }
}
