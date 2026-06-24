import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  static const String _apiKey = '24b4a83021f79c697718670aa5d2d176';
  static const String _weatherBaseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const String _forecastBaseUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  static http.Client client = http.Client();

  // Stores the last weather data fetched by the 'getWeatherByCity' method
  static Map<String, dynamic>? lastWeatherData;

  static Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    final url = Uri.parse(
        '$_weatherBaseUrl?q=$city&appid=$_apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      lastWeatherData = json.decode(response.body);
      return lastWeatherData!;
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  // Method to get weather forecast by city
  static Future<List<Map<String, dynamic>>> getForecastByCity(
      String city) async {
    final url = Uri.parse(
        '$_forecastBaseUrl?q=$city&appid=$_apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['list']);
    } else {
      throw Exception('Failed to load forecast data');
    }
  }

  // Method to get weather data for the current location
  static Future<Map<String, dynamic>> getWeatherByLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final url = Uri.parse(
        '$_weatherBaseUrl?lat=${position.latitude}&lon=${position
            .longitude}&appid=$_apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data for location');
    }
  }

  // Method to get weather forecast for the current location
  static Future<List<Map<String, dynamic>>> getForecastByLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final url = Uri.parse(
        '$_forecastBaseUrl?lat=${position.latitude}&lon=${position
            .longitude}&appid=$_apiKey&units=metric');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['list']);
    } else {
      throw Exception('Failed to load forecast data for location');
    }
  }

  // Method to get a 3-day forecast by a city
  static Future<List<Map<String, dynamic>>> get3DayForecast(String city) async {
    final url = Uri.parse(
        '$_forecastBaseUrl?q=$city&appid=$_apiKey&units=metric&cnt=3');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['list']);
    } else {
      throw Exception('Failed to load 3-day forecast');
    }
  }

  // Method to get a 5-day forecast by a city
  static Future<List<Map<String, dynamic>>> get5DayForecast(String city) async {
    final url = Uri.parse(
        '$_forecastBaseUrl?q=$city&appid=$_apiKey&units=metric&cnt=5');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['list']);
    } else {
      throw Exception('Failed to load 5-day forecast');
    }
  }

  // Method to get a weekly forecast by a city
  static Future<List<Map<String, dynamic>>> getWeeklyForecast(String city) async {
    final url = Uri.parse(
        '$_forecastBaseUrl?q=$city&appid=$_apiKey&units=metric&cnt=7');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['list']);
    } else {
      throw Exception('Failed to load weekly forecast');
    }
  }

  //returns a description
  static String parseWeatherData(Map<String, dynamic> data, bool isCelsius) {
    final main = data['main'];
    final temperature = main['temp'] as double;
    final weather = data['weather'][0];
    final description = weather['description'] as String;

    final temp = isCelsius ? temperature : (temperature * 9 / 5) + 32;
    return 'Temperature: ${temp.toStringAsFixed(1)} °${isCelsius
        ? 'C'
        : 'F'}\n$description';
  }

  // Method to get the correct weather background based on the description
  static String getWeatherBackground(String description) {
    final desc = description.toLowerCase();

    if (desc.contains('sun') || desc.contains('clear')) {
      return 'sunny.jpg';
    } else if (desc.contains('cloud')) {
      return 'cloudy.jpg';
    } else if (desc.contains('rain') || desc.contains('drizzle')) {
      return 'rainy.jpg';
    } else if (desc.contains('snow')) {
      return 'snowy.jpg';
    } else if (desc.contains('storm') || desc.contains('thunder')) {
      return 'thunderstorm.jpg';
    } else {
      return 'sunny.jpg';
    }
  }
}
