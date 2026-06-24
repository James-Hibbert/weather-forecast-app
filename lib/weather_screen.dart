import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:weatherprojectnew/pages/auth_page.dart';
import 'notification_service.dart';
import 'services/camera_screen.dart';
import 'services/image_classifier.dart';
import 'services/weather_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _isDetecting = false;
  final TextEditingController _cityController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _usingCapturedImage = false;



  bool _isListening = false;
  bool _isLoading = false;
  bool isCelsius = true;

  String _weatherInfo = 'No data fetched';
  ImageProvider? _backgroundImage;
  String? _backgroundAssetKey;
  String _detectedWeather = '';

  File? _capturedImage;

  List<Map<String, dynamic>> _forecastData = [];
  List<Map<String, dynamic>> _rawForecastData = [];

  @override
  void dispose() {
    _speech.stop();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() => _cityController.text = result.recognizedWords);
        _fetchWeather();
      });
    } else {
      setState(() => _weatherInfo = "Speech recognition is not available");
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  Future<void> _fetchWeather() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      setState(() => _weatherInfo = 'Please enter a city');
      return;
    }

    setState(() {
      _isLoading = true;
      _usingCapturedImage = false; //  Reset to use asset image
      _backgroundImage = null;     //  Clear the file image
    });


    try {
      final weatherData = await WeatherService.getWeatherByCity(city);
      if (weatherData != null) {
        setState(() {
          _weatherInfo = WeatherService.parseWeatherData(weatherData, isCelsius);
        });
      } else {
        setState(() {
          _weatherInfo = 'No data found';
        });
        return;
      }

      final forecast = await WeatherService.getForecastByCity(city);
      final description = weatherData['weather'][0]['description'];

      setState(() {
        if (!_usingCapturedImage) {
          final backgroundKey = WeatherService.getWeatherBackground(description);
          _backgroundAssetKey = backgroundKey;
          _backgroundImage = null;
        }

        _cityController.text = weatherData['name'];
        _rawForecastData = forecast;
        _convertForecastTemperatures();
      });

      await NotificationService.displayNotification(
        notificationTitle: 'Weather Alert',
        notificationBody: 'Current weather in ${_cityController.text}: $description',
      );
    } catch (e) {
      setState(() {
        _weatherInfo = 'Error fetching weather data: $e';
        _forecastData.clear();
        _rawForecastData.clear();
      });
      print('Error fetching weather data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }




  void _convertForecastTemperatures() {
    Map<String, List<Map<String, dynamic>>> dailyTemps = {};

    for (var item in _rawForecastData) {
      final tempC = (item['main']['temp'] as num).toDouble();
      final temp = isCelsius ? tempC : (tempC * 9 / 5) + 32;

      final timestamp = item['dt'] as int;
      final date = DateTime.fromMillisecondsSinceEpoch(
          timestamp * 1000, isUtc: true).toLocal();

      final formattedDate = "${date.day.toString().padLeft(2, '0')}/${date.month
          .toString().padLeft(2, '0')}/${date.year}";

      dailyTemps.putIfAbsent(formattedDate, () => []).add({
        'temp': temp,
        'dateTime': date,
      });
    }

    _forecastData = dailyTemps.entries.map((entry) {
      final temps = entry.value;

      // Average temperature
      final avgTemp = temps.map((e) => e['temp'] as double).reduce((a, b) =>
      a + b) / temps.length;

      // Find the time closest to 12:00 PM
      final noon = DateTime(
        temps.first['dateTime'].year,
        temps.first['dateTime'].month,
        temps.first['dateTime'].day,
        12,
        0,
      );

      temps.sort((a, b) {
        final diffA = (a['dateTime'] as DateTime).difference(noon).abs();
        final diffB = (b['dateTime'] as DateTime).difference(noon).abs();
        return diffA.compareTo(diffB);
      });

      final closestToNoon = temps.first['dateTime'] as DateTime;
      final formattedTime = "${closestToNoon.hour.toString().padLeft(
          2, '0')}:${closestToNoon.minute.toString().padLeft(2, '0')}";

      return {
        'formattedDate': entry.key,
        'formattedTime': formattedTime,
        'temp': double.parse(avgTemp.toStringAsFixed(1)),
      };
    }).toList();
  }


  Future<void> _fetch3DayForecast() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      setState(() => _weatherInfo = 'Please enter a city');
      return;
    }
    setState(() => _isLoading = true);

    try {
      final forecast = await WeatherService.getForecastByCity(city);

      if (forecast != null) {
        // Filter out the forecast data for the next 3 days
        List<Map<String, dynamic>> next3DaysForecast = [];
        final now = DateTime.now();
        final threeDaysFromNow = now.add(Duration(days: 3));

        for (var item in forecast) {
          final timestamp = item['dt'] as int;
          final date = DateTime.fromMillisecondsSinceEpoch(
              timestamp * 1000, isUtc: true).toLocal();

          // Only adds forecast data if it falls within the next 3 days
          if (date.isAfter(now) && date.isBefore(threeDaysFromNow)) {
            next3DaysForecast.add(item);
          }
        }

        setState(() {
          _rawForecastData = next3DaysForecast;
          _convertForecastTemperatures();
        });
      } else {
        setState(() {
          _weatherInfo = 'No data found for the next 3 days';
          _forecastData.clear();
          _rawForecastData.clear();
        });
      }
    } catch (e) {
      setState(() {
        _weatherInfo = 'Error fetching forecast data';
        _forecastData.clear();
        _rawForecastData.clear();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }


  Future<void> _fetchWeatherForCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _usingCapturedImage = false; //  Reset
      _backgroundImage = null;     //  Clear
    });


    try {
      final weatherData = await WeatherService.getWeatherByLocation();
      final forecast = await WeatherService.getForecastByLocation();
      final description = weatherData['weather'][0]['description'];

      setState(() {
        _weatherInfo = WeatherService.parseWeatherData(weatherData, isCelsius);

        // Only update the background if no photo is being used
        if (!_usingCapturedImage) {
          final backgroundKey = WeatherService.getWeatherBackground(description);
          _backgroundAssetKey = backgroundKey;
          _backgroundImage = null;
        }

        _cityController.text = weatherData['name'];
        _rawForecastData = forecast;
        _convertForecastTemperatures();
      });

      await NotificationService.displayNotification(
        notificationTitle: 'Weather Alert',
        notificationBody: 'Current weather in ${weatherData['name']}: $description',
      );
    } catch (e) {
      setState(() {
        _weatherInfo = 'Error fetching location-based weather: $e';
        _forecastData.clear();
        _rawForecastData.clear();
      });
      print('Error fetching location-based weather: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final canShare = _weatherInfo.isNotEmpty &&
        _weatherInfo != 'No data fetched' &&
        _weatherInfo != 'Please enter a city' &&
        !_weatherInfo.startsWith('Error');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Info'),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await FirebaseAuth.instance
                              .signOut(); //Sign out of Firebase


                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const AuthPage()),
                            // Navigate to login page
                                (
                                route) => false, // Clears everything so it makes sure user is logged out
                          );
                        },
                        child: const Text(
                            'Sign Out'),
                      ),

                    ],
                  );
                },
              );
            },
            tooltip: 'Log Out',
          ),
        ],
      ),

      floatingActionButton: canShare
          ? FloatingActionButton(
        onPressed: () => Share.share('Weather Forecast:\n$_weatherInfo'),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.share),
        tooltip: 'Share Forecast',
      )
          : null,
      body: Stack(
        children: [
      Container(
      decoration: BoxDecoration(
      image: DecorationImage(
        image: _usingCapturedImage && _backgroundImage != null
            ? _backgroundImage!
            : AssetImage('assets/images/${_backgroundAssetKey ?? 'sunny.jpg'}'),
        fit: BoxFit.cover,
    ),
    ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: 'Enter city',
                      suffixIcon: IconButton(
                        icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                        onPressed: _isListening
                            ? _stopListening
                            : _startListening,
                      ),
                    ),
                    onSubmitted: (_) => _fetchWeather(),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: Text('Display in Celsius'),
                    value: isCelsius,
                    onChanged: (value) {
                      setState(() {
                        isCelsius = value;
                        _convertForecastTemperatures();
                        if (_rawForecastData.isNotEmpty) {
                          _weatherInfo = WeatherService.parseWeatherData(
                              WeatherService.lastWeatherData ?? {}, isCelsius);
                        }
                      });
                    },
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _fetchWeather,
                        icon: const Icon(Icons.search),
                        label: const Text('Fetch Weather'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _fetchWeatherForCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Current Location'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _fetch3DayForecast,
                        icon: const Icon(Icons.calendar_view_day),
                        label: const Text('3-Day Forecast'),
                      ),
    ElevatedButton.icon(
    onPressed: _isDetecting ? null : _openCamera, //Disables camera button while its loading
    icon: _isDetecting
    ? const SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    )
        : const Icon(Icons.camera_alt),
    label: Text(_isDetecting ? 'Detecting...' : 'Detect with Camera'),
    ),

    if (_isLoading)
    const Center(child: CircularProgressIndicator()),

    if (!_isLoading && _weatherInfo.isNotEmpty)
    Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Text(
    _weatherInfo,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 18, color: Colors.white),
    ),
    ),

    if (_forecastData.isNotEmpty)
    Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: ListView.builder(
    itemCount: _forecastData.length,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemBuilder: (context, index) {
    final forecast = _forecastData[index];
    return Card(
    color: Colors.blueGrey[200],
    child: ListTile(
    title: Text(forecast['formattedDate']),
    subtitle: Text(forecast['formattedTime']),
    trailing: Text('${forecast['temp']}°'),
    ),
    );
    },
    ),
    ),
    ],
    ),
    ],
    ),
    ),
      ),
    ],
      ),
    );
  }

  Future<void> _openCamera() async {
    setState(() {
      _isDetecting = true;
    });

    final image = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          onImageCaptured: (capturedImage) async {
            setState(() {
              _capturedImage = capturedImage;
              _backgroundImage = FileImage(capturedImage);
              _usingCapturedImage = true;
            });

            final description = await ImageClassifier.classifyImage(capturedImage);

            if (description != null && description.isNotEmpty) {
              setState(() {
                _detectedWeather = description;
                });
            } else {
              setState(() {
                _detectedWeather = 'No description available';
              });
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Detected: $_detectedWeather')),
            );

            setState(() {
              _isDetecting = false;
            });
          },
        ),
      ),
    );

    if (image == null) {
      setState(() {
        _isDetecting = false;
      });
    }
  }
}