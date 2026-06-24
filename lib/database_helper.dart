import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  static final DatabaseHelper instance = DatabaseHelper._init();

  // Refers to database
  static Database? _database;

  // Private constructor
  DatabaseHelper._init();

  // Getter for the database
  Future<Database> get database async {
    if (_database != null) return _database!;  // Return existing db if available
    _database = await _initDatabase();  // Otherwise initialise the database
    return _database!;
  }

  // Initialise the database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();  // Get the path to the databases directory
    final path = join(dbPath, 'weather_app.db');  // Define the path for the database

    // Open the database and create it if it doesn't exist
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,  // If the database is created, initialise it with a table
    );
  }

  // Create the weather table
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE weather (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        city TEXT NOT NULL,
        temp REAL NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  // Insert a weather record with timestamp
  Future<int> insertWeather(Map<String, dynamic> weatherData) async {
    final db = await instance.database;

    // Add timestamp to the data
    weatherData['timestamp'] = DateTime.now().toIso8601String();

    return await db.insert('weather', weatherData);  // Insert the data into the table
  }

  // Get all the weather records
  Future<List<Map<String, dynamic>>> getAllWeather() async {
    final db = await instance.database;
    return await db.query('weather', orderBy: 'id DESC');  // Query all records ordered by id
  }

  // Get weather records by city
  Future<List<Map<String, dynamic>>> getWeatherByCity(String city) async {
    final db = await instance.database;
    return await db.query(
      'weather',
      where: 'city = ?',
      whereArgs: [city],
      orderBy: 'id DESC',
    );
  }

  // Update a weather record by ID
  Future<int> updateWeather(int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update(
      'weather',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a weather record by ID
  Future<int> deleteWeather(int id) async {
    final db = await instance.database;
    return await db.delete('weather', where: 'id = ?', whereArgs: [id]);
  }

  // Clear all records from the weather table
  Future<void> clearAllWeather() async {
    final db = await instance.database;
    await db.delete('weather');
  }

  // Close the database connection
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
