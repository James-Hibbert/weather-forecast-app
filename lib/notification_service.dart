import 'dart:convert';
import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static const String _weatherApiKey = '24b4a83021f79c697718670aa5d2d176';

  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'weather_channel',
          channelName: 'Weather Alerts',
          channelDescription: 'Notification channel for weather updates',
          defaultColor: const Color(0xFF3D7DFF),
          ledColor: const Color(0xFF3D7DFF),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableLights: true,
          enableVibration: true,
          locked: false,
        ),
      ],
      debug: true,
    );

    await requestNotificationPermissions();
  }

  static Future<bool> requestNotificationPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
      isAllowed = await AwesomeNotifications().isNotificationAllowed();
    }
    return isAllowed;
  }

  static Future<void> displayNotification({
    required String notificationTitle,
    required String notificationBody,
    String? summary,
    Map<String, String>? notificationPayload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        channelKey: 'weather_channel',
        title: notificationTitle,
        body: notificationBody,
        summary: summary,
        payload: notificationPayload ?? {},
        notificationLayout: NotificationLayout.Default,
        autoDismissible: true,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
      ),
    );
  }

  static void setListeners() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (receivedNotification) async {
        print("Notification clicked: ${receivedNotification.title}");
      },
      onNotificationCreatedMethod: (createdNotification) async {
        print("Notification created: ${createdNotification.title}");
      },
      onNotificationDisplayedMethod: (displayedNotification) async {
        print("Notification displayed: ${displayedNotification.title}");
      },
      onDismissActionReceivedMethod: (dismissedNotification) async {
        print("Notification dismissed: ${dismissedNotification.title}");
      },
    );
  }

  static Future<void> checkWeatherAndNotify() async {
    try {
      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double lat = position.latitude;
      double lon = position.longitude;

      // Call OpenWeatherMap API
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_weatherApiKey&units=metric',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weatherMain = data['weather'][0]['main'].toString().toLowerCase();

        if (weatherMain.contains('rain') || weatherMain.contains('snow')) {
          await displayNotification(
            notificationTitle: 'Weather Alert',
            notificationBody: 'It\'s expected to ${weatherMain == 'rain' ? 'rain' : 'snow'} soon in your area.',
          );
        }
      } else {
        print('Failed to fetch weather data');
      }
    } catch (e) {
      print('Error checking weather: $e');
    }
  }
}
