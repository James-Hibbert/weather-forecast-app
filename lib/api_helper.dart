import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHelper {
  static const String _apiKey = "24b4a83021f79c697718670aa5d2d176";
  static const String _baseUrl = "https://api.openweathermap.org/data/2.5/weather";


  static Future<Map<String, dynamic>> fetchWeather(String city, {http.Client? client}) async {
    client ??= http.Client();

    final response = await client.get(Uri.parse('$_baseUrl?q=$city&appid=$_apiKey&units=metric'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather');
    }
  }
}
