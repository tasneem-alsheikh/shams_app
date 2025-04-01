import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // For date formatting

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String apiKey = "de67cbaf0d857be4d0227ac068765f68";
  String temperature = "--";
  String weatherDescription = "--";
  String city = "--";
  String humidity = "--";
  String uvIndex = "--";
  String? userName;
  String currentDay = DateFormat('EEEE').format(DateTime.now()); // Get current day

  @override
  void initState() {
    super.initState();
    _loadUserData();
    getLocationAndFetchWeather();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => userName = prefs.getString('firstName'));
  }

  Future<void> getLocationAndFetchWeather() async {
    try {
      Position position = await _determinePosition();
      await fetchWeather(position.latitude, position.longitude);
      await fetchUVIndex(position.latitude, position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error("Location services are disabled.");
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error("Location permission denied.");
    }
    if (permission == LocationPermission.deniedForever) return Future.error("Location permissions are permanently denied.");
    return await Geolocator.getCurrentPosition();
  }

  Future<void> fetchWeather(double lat, double lon) async {
    String url = "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temperature = "${data['main']['temp'].toStringAsFixed(0)}°";
          weatherDescription = data['weather'][0]['description'];
          city = data['name'];
          humidity = "${data['main']['humidity']}%";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching weather: $e')));
    }
  }

  Future<void> fetchUVIndex(double lat, double lon) async {
    String url = "http://api.openweathermap.org/data/2.5/uvi?lat=$lat&lon=$lon&appid=$apiKey";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          uvIndex = data['value'].toString();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching UV index: $e')));
    }
  }

  List<Widget> _buildWarnings() {
    List<Widget> warnings = [];
    double temp = double.tryParse(temperature.split('°')[0]) ?? 0;

    if (temp >= 30 && temp < 35) {
      warnings.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400, width: 0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFD89E00),
                  size: 60,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Heat Risk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Moderate',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Stay hydrated and take breaks in shade',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else if (temp >= 35 && temp < 40) {
      warnings.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFD89E00),
                  size: 30,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Heat Risk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'High',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Limit outdoor activity, stay hydrated',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else if (temp >= 40) {
      warnings.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400, width: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFD89E00),
                  size: 60,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Heat Risk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Extreme',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Avoid outdoor activity if possible',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return warnings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the logo
                  children: [
                    Image.asset('assets/logo.jpg', width: 40, height: 40),
                    const SizedBox(width: 8),
                    const Text(
                      'Shams',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD89E00),
                      ),
                    ),
                  ],
                ),
              ),

              // Location
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Color(0xFFD89E00)),
                    const SizedBox(width: 4),
                    Text(
                      city,
                      style: const TextStyle(fontSize: 16, color: Color(0xFFD89E00)),
                    ),
                  ],
                ),
              ),

              // Day
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  currentDay.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),

              // Temperature (Centered)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the temperature
                  children: [
                    Text(
                      temperature,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.brightness_1,
                      color: Colors.red,
                      size: 12,
                    ),
                  ],
                ),
              ),

              // Humidity and UV Index
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Humidity: $humidity',
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    Text(
                      'UV Index: $uvIndex',
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),

              // Heat Risk Warning
              ..._buildWarnings(),
            ],
          ),
        ),
      ),
    );
  }
}