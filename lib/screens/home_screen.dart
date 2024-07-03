import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/models/weather.dart';
import 'weather_details_screen.dart';
import '../provider/weather_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  final List<String> _recentCities = []; // List to store recent cities

  @override
  void initState() {
    super.initState();
    _getCurrentLocationWeather(); // Fetch weather data for the current location when the screen initializes
  }

  Future<void> _getCurrentLocationWeather() async {
    final weatherProvider = Provider.of<WeatherProvider>(context,
        listen: false); // Get the WeatherProvider without listening for changes

    // Check and request location permission from the user
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Handle different permission statuses
    if (permission == LocationPermission.denied) {
      _showSnackBar(
          'Location permissions are denied'); // Show a snack bar if permissions are denied
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar(
          'Location permissions are permanently denied, we cannot request permissions.'); // Show a snack bar if permissions are permanently denied
      return;
    }

    try {
      await weatherProvider
          .fetchCurrentLocationWeather(); // Fetch weather data for the current location
    } catch (e) {
      if (e is Exception) {
        _showSnackBar(
            'Failed to fetch weather: ${e.toString()}'); // Show a snack bar if an error occurs
      }
    }

    if (mounted) {
      setState(
          () {}); // Ensure the UI updates only if the widget is still mounted
    }
  }

  // Show a snack bar with a message
  void _showSnackBar(String message) {
    if (!mounted) return; // Ensure the widget is still mounted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)), // Display the message in a snack bar
    );
  }

  // Handle searching for weather by city
  void _searchWeather(String city) {
    if (city.isNotEmpty) {
      final weatherProvider = Provider.of<WeatherProvider>(context,
          listen:
              false); // Get the WeatherProvider without listening for changes
      weatherProvider.fetchWeatherByCity(city).then((_) {
        // Add the city to the recent cities list
        if (!_recentCities.contains(city)) {
          if (_recentCities.length >= 4) {
            _recentCities.removeAt(
                0); // Remove the oldest city if there are 4 or more cities
          }
          setState(() {
            _recentCities
                .add(city); // Add the new city to the recent cities list
          });
        }

        // Navigate to the WeatherDetailsScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WeatherDetailsScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight =
        MediaQuery.of(context).size.height; // Get the screen height

    return Scaffold(
      resizeToAvoidBottomInset: true, // Adjust the UI for the keyboard
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          return Stack(
            children: [
              // Display the background image based on whether it's day or night
              if (weatherProvider.currentLocationWeather != null)
                Image.asset(
                  weatherProvider.currentLocationWeather!.isDayTime()
                      ? 'assets/day_background.png' // Day background image
                      : 'assets/night_background.png', // Night background image
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              else
                Container(), // Empty container while waiting for data
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: 50.0,
                          bottom: screenHeight *
                              0.1), // Dynamic bottom padding based on screen height
                      child: Column(
                        children: [
                          // Display weather information if available
                          if (weatherProvider.currentLocationWeather != null)
                            _buildWeatherInfo(weatherProvider)
                          else
                            Container(), // Empty container while waiting for data
                          const SizedBox(height: 10),
                          if (weatherProvider.currentLocationWeather != null)
                            Text(
                              weatherProvider.currentLocationWeather!.condition,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                    color: Colors.white, // Text color
                                  ),
                            ),
                          const SizedBox(height: 40),
                          // Autocomplete widget for recent cities
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Autocomplete<String>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                // Filter recent cities based on the user input
                                return _recentCities.where((city) {
                                  final cityLower = city.toLowerCase();
                                  final queryLower =
                                      textEditingValue.text.toLowerCase();
                                  return cityLower.contains(
                                      queryLower); // Return cities that match the query
                                });
                              },
                              onSelected: (String city) {
                                _cityController.text =
                                    city; // Set the text field value to the selected city
                                _searchWeather(
                                    city); // Fetch weather for the selected city
                              },
                              fieldViewBuilder: (context, controller, focusNode,
                                  onFieldSubmitted) {
                                _cityController.text = controller
                                    .text; // Sync text field controller with city controller
                                return TextField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Enter city name', // Hint text for the text field
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors
                                        .white, // Text field background color
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 12),
                                  ),
                                );
                              },
                              optionsViewBuilder:
                                  (context, onSelected, options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    elevation: 4.0,
                                    child: ListView(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      children: options.map((String option) {
                                        return ListTile(
                                          title: Text(option),
                                          onTap: () => onSelected(
                                              option), // Handle selection of an option
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              final city = _cityController
                                  .text; // Get the city name from the text field
                              _searchWeather(
                                  city); // Fetch weather for the city
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, // Button color
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30, // Horizontal padding
                                vertical: 12, // Vertical padding
                              ),
                            ),
                            child: const Text('Search'), // Button text
                          ),
                          const SizedBox(height: 10),
                          if (weatherProvider.currentLocationWeather != null)
                            Container(
                              padding: const EdgeInsets.all(5),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: screenHeight *
                                      0.05), // Dynamic vertical margin based on screen height
                              decoration: BoxDecoration(
                                color: Colors
                                    .black54, // Container background color
                                borderRadius: BorderRadius.circular(
                                    12), // Rounded corners
                              ),
                              child: GridView(
                                shrinkWrap:
                                    true, // Ensure the GridView only takes up as much space as needed
                                physics:
                                    const NeverScrollableScrollPhysics(), // Disable scrolling for the GridView
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      2, // Number of columns in the grid
                                  crossAxisSpacing:
                                      8, // Horizontal spacing between items
                                  mainAxisSpacing:
                                      2, // Vertical spacing between items
                                  childAspectRatio:
                                      1.8, // Aspect ratio of each grid item to avoid overflow
                                ),
                                children: [
                                  _buildDetail(
                                    context,
                                    '${weatherProvider.currentLocationWeather!.humidity}%',
                                    'Humidity',
                                    Icons.water_drop, // Icon for humidity
                                  ),
                                  _buildDetail(
                                    context,
                                    '${weatherProvider.currentLocationWeather!.visibility / 1000} km',
                                    'Visibility',
                                    Icons.visibility, // Icon for visibility
                                  ),
                                  _buildDetail(
                                    context,
                                    '${weatherProvider.currentLocationWeather!.clouds}%',
                                    'Clouds',
                                    Icons.cloud, // Icon for clouds
                                  ),
                                  _buildDetail(
                                    context,
                                    '${weatherProvider.currentLocationWeather!.windSpeed} m/s',
                                    'Wind Speed',
                                    Icons.air, // Icon for wind speed
                                  ),
                                  _buildDetail(
                                    context,
                                    weatherProvider
                                        .currentLocationWeather!.sunrise
                                        .toDateTime()
                                        .format('HH:mm'),
                                    'Sunrise',
                                    Icons.wb_sunny, // Icon for sunrise
                                  ),
                                  _buildDetail(
                                    context,
                                    weatherProvider
                                        .currentLocationWeather!.sunset
                                        .toDateTime()
                                        .format('HH:mm'),
                                    'Sunset',
                                    Icons.nights_stay, // Icon for sunset
                                  ),
                                ],
                              ),
                            ),
                          if (weatherProvider.isLoading)
                            const Center(
                                child:
                                    CircularProgressIndicator()) // Show a loading spinner while fetching data
                          else if (weatherProvider.error.isNotEmpty)
                            Center(
                                child: Text(weatherProvider
                                    .error)) // Show an error message if there is an error
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Build the weather information display
  Widget _buildWeatherInfo(WeatherProvider weatherProvider) {
    final weather = weatherProvider.currentLocationWeather!;
    final currentDateTime =
        weatherProvider.getCurrentDateTime(); // Get the current date and time

    return Column(
      children: [
        Text(
          weather.cityName,
          semanticsLabel: 'City Name', // Accessibility label
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.white,
                fontSize: 45, // Font size for city name
              ),
        ),
        const SizedBox(height: 10),
        Text(
          '${currentDateTime.format('HH:mm')}, ${currentDateTime.getDayOfWeek()}', // Display current time and day of the week
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.white, // Text color
              ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${weather.temperature.toStringAsFixed(0)}°C', // Display current temperature
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    color: Colors.white, // Text color
                    fontSize: 40, // Font size for temperature
                  ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${weather.minTemp.toStringAsFixed(0)}°C', // Display minimum temperature
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.white, // Text color
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Min Temp', // Label for minimum temperature
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 12, // Smaller font size for label
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${weather.maxTemp.toStringAsFixed(0)}°C', // Display maximum temperature
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.white, // Text color
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Max Temp', // Label for maximum temperature
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 12, // Smaller font size for label
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Build individual weather detail widgets
  Widget _buildDetail(
      BuildContext context, String value, String title, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 30), // Icon on top
        const SizedBox(height: 2),
        Text(
          value, // Display the detail value
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.white,
                fontSize: 16, // Font size for detail value
              ),
        ),
        const SizedBox(height: 4),
        Text(
          title, // Display the detail title
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.white,
                fontSize: 12, // Smaller font size for detail title
              ),
        ),
      ],
    );
  }
}
