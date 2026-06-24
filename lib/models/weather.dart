class Weather {
  final int? id;
  final String city;
  final double temp;
  final String timestamp;

  Weather({
    this.id,
    required this.city,
    required this.temp,
    required this.timestamp,
  });

  // Convert Weather object to a Map for a database update
  Map<String, dynamic> toMap() => {
    'id': id,
    'city': city,
    'temp': temp,
    'timestamp': timestamp,
  };

  // Creates a Weather object from a Map
  factory Weather.fromMap(Map<String, dynamic> map) => Weather(
    id: map['id'],
    city: map['city'],
    temp: map['temp'],
    timestamp: map['timestamp'],
  );
}
