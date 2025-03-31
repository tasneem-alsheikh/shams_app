import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  String? userName;

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
      fetchWeather(position.latitude, position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching location: $e')));
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
          temperature = "${data['main']['temp'].toStringAsFixed(1)}°C";
          weatherDescription = data['weather'][0]['description'];
          city = data['name'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching weather: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hello, ${userName ?? 'User'}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFD89E00)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Color(0xFFD89E00)),
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wb_sunny, size: 80, color: Color(0xFFD89E00)),
                    const SizedBox(height: 16),
                    Text(
                      city,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      temperature,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(
                      weatherDescription,
                      style: TextStyle(fontSize: 20, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: getLocationAndFetchWeather,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD89E00)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}