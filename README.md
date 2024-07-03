# Weather App

A Flutter application that provides current weather conditions and air quality information for a specified city or the user's current location.

## Features

- Fetch weather data by city name.
- Fetch weather data based on the current location.
- View air quality index (AQI) along with weather conditions.
- Recent cities list for autocomplete suggestions.

## Getting Started

To get this app up and running on your local machine, follow these instructions:

### Prerequisites

Ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.10.0 or later)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter SDK)
- An IDE like [Visual Studio Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Akshansh2515/Weather-App.git
   
2. Navigate to the project directory:

            cd weather-app


3. Install dependencies: 

       flutter pub get


6. Obtain an OpenWeatherMap API key:
      a- Go to OpenWeatherMap and sign up for an API key.
      b- Replace the apiKey in lib/services/weather_services.dart with your API key:  
          
             final String apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';


## Running the App
            flutter run


## Running Tests
            flutter test

## Future Improvements
Here are some ideas for future updates to the app:

* Add support for multiple languages.
* Include a more detailed weather forecast (hourly, weekly).
* Implement a settings page to allow users to switch between metric and imperial units.
* Improve the UI with themes and animations.


## Contributing

If you would like to contribute to this project, please fork the repository and submit a pull request with your changes. For major changes, please open an issue first to discuss what you would like to change.