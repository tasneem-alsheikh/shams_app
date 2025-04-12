import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String apiKey = "de67cbaf0d857be4d0227ac068765f68";
  String temperature = "--";
  String weatherDescription = "--";
  String weatherIcon = "01d"; // Default to clear day; updated by API
  String city = "--";
  String humidity = "--";
  String uvIndex = "--";
  String? userName;
  String currentDay = DateFormat('EEEE').format(DateTime.now());

  List<String> _adviceList = [];
  bool _isLoadingAdvice = false;
  int _waterCupsDrank = 0;
  final int _totalWaterCups = 8;

  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _startPeriodicUpdates();
    _loadUserData();
    _loadWaterData();
    getLocationAndFetchWeather().then((_) => _generatePersonalizedAdvice());
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicUpdates() {
    _fetchDataAndUpdate();
    _updateTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      _fetchDataAndUpdate();
    });
  }

  Future<void> _fetchDataAndUpdate() async {
    if (!mounted) return;
    try {
      await getLocationAndFetchWeather();
      await _generatePersonalizedAdvice();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => userName = prefs.getString('firstName'));
  }

  Future<void> _loadWaterData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setState(() {
      _waterCupsDrank = prefs.getInt('waterCups_$today') ?? 0;
    });
  }

  Future<void> _saveWaterData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await prefs.setInt('waterCups_$today', _waterCupsDrank);
  }

  void _updateWaterCups(int cups) {
    setState(() {
      _waterCupsDrank = cups;
    });
    _saveWaterData();
  }

  Future<void> getLocationAndFetchWeather() async {
    try {
      final position = await _determinePosition();
      await Future.wait([
        fetchWeather(position.latitude, position.longitude),
        fetchUVIndex(position.latitude, position.longitude),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Weather update failed: ${e.toString()}')),
        );
      }
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
          weatherIcon = data['weather'][0]['icon'];
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
        _buildAlertBox(
          title: 'Heat Risk',
          level: 'Moderate',
          levelColor: Colors.orange,
          message: 'Stay hydrated and take breaks in shade',
          icon: Icons.warning_rounded,
          iconColor: const Color(0xFFD89E00),
        ),
      );
    } else if (temp >= 35 && temp < 40) {
      warnings.add(
        _buildAlertBox(
          title: 'Heat Risk',
          level: 'High',
          levelColor: Colors.red,
          message: 'Limit outdoor activity, stay hydrated',
          icon: Icons.warning_rounded,
          iconColor: const Color(0xFFD89E00),
        ),
      );
    } else if (temp >= 40) {
      warnings.add(
        _buildAlertBox(
          title: 'Heat Risk',
          level: 'Extreme',
          levelColor: Colors.red,
          message: 'Avoid outdoor activity if possible',
          icon: Icons.warning_rounded,
          iconColor: const Color(0xFFD89E00),
        ),
      );
    }

    return warnings;
  }

  Widget _buildAlertBox({
    required String title,
    required String level,
    required Color levelColor,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 48,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level,
                      style: GoogleFonts.nunito(
                        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: levelColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: GoogleFonts.nunito(
                        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterTracker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.water_drop,
                    color: Color(0xFF4AA3DF),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Water Tracker',
                    style: GoogleFonts.nunito(
                      textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tap a cup to track your water intake',
                style: GoogleFonts.nunito(
                  textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _totalWaterCups,
                      (index) => GestureDetector(
                    onTap: () {
                      _updateWaterCups(index + 1);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        children: [
                          Icon(
                            index < _waterCupsDrank ? Icons.local_drink : Icons.water_drop_outlined,
                            color: index < _waterCupsDrank ? const Color(0xFF4AA3DF) : Colors.grey.shade400,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${index + 1}',
                            style: GoogleFonts.nunito(
                              textStyle: TextStyle(
                                fontSize: 12,
                                color: index < _waterCupsDrank ? const Color(0xFF4AA3DF) : Colors.grey.shade400,
                                fontWeight: index < _waterCupsDrank ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _waterCupsDrank / _totalWaterCups,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4AA3DF)),
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_waterCupsDrank of $_totalWaterCups cups',
                    style: GoogleFonts.nunito(
                      textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4AA3DF),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _waterCupsDrank = 0;
                      });
                      _saveWaterData();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(
                      'Reset',
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generatePersonalizedAdvice() async {
    setState(() => _isLoadingAdvice = true);

    final prefs = await SharedPreferences.getInstance();
    final userData = {
      'gender': prefs.getString('gender') ?? 'Not specified',
      'age': prefs.getString('age') ?? 'Unknown',
      'weight': prefs.getString('weight') ?? 'Unknown',
      'illnesses': prefs.getStringList('illnesses')?.join(", ") ?? "None",
      'medications': prefs.getStringList('medications')?.join(", ") ?? "None",
      'currentWeather': {
        'temperature': temperature,
        'uvIndex': uvIndex,
        'humidity': humidity,
      },
    };

    final prompt = """
  Generate 3 concise health recommendations for:
  
  **User Profile:**
  - Gender: ${userData['gender']}
  - Age: ${userData['age']}
  - Conditions: ${userData['illnesses']}
  - Medications: ${userData['medications']}
  
  **Current Weather:**
  - Temp: ${(userData['currentWeather'] as Map)['temperature'] ?? 'N/A'}°C
  - UV: ${(userData['currentWeather'] as Map)['uvIndex'] ?? 'N/A'}
  - Humidity: ${(userData['currentWeather'] as Map)['humidity'] ?? 'N/A'}%
  
  Focus on weather interactions with health conditions.
  Just Three simple, easy and straightforward advices. each in one or 2 lines
  do not mention the reasoning behind the advice or explanation or why to take the advice.
  Only mention specific advise such as the number of glasses of water to drink.
  Do not mention the UV index, humidity, temperature, illnesses or Medications values in the advice.
  Do not include numbers or numbering at the beginning of each advice.
  """;

    try {
      _adviceList = await _callMistralAPI(prompt);
    } catch (e) {
      _adviceList = ['Failed to generate advice: $e'];
    } finally {
      setState(() => _isLoadingAdvice = false);
    }
  }

  Future<List<String>> _callMistralAPI(String prompt) async {
    try {
      const apiKey = 'YTAPiykxZ7wbHFuCEwEyA4m2AacP7Y2p';
      final response = await http.post(
        Uri.parse('https://api.mistral.ai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'mistral-small',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a medical assistant. Provide 3 concise bullet points without leading asterisks, bullets, or numbers.'
            },
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      final jsonResponse = jsonDecode(response.body);
      final content = jsonResponse['choices']?[0]?['message']?['content'] as String?;

      // Improved cleaning: remove all numbering, bullets, and extra characters
      if (content == null || content.isEmpty) {
        return ['Could not generate advice'];
      }

      List<String> adviceItems = content
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) {
        // Remove numbering patterns like "1. ", "1) ", etc.
        String cleaned = line.replaceAll(RegExp(r'^\d+[\.\)\-]\s*'), '');
        // Remove bullet points and other markers
        cleaned = cleaned.replaceAll(RegExp(r'^[\*\•\-\s]+'), '');
        return cleaned.trim();
      })
          .toList();

      return adviceItems.isEmpty ? ['Could not generate advice'] : adviceItems;
    } catch (e) {
      return ['Error: $e'];
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Clear user session data
      await prefs.remove('firstName');
      await prefs.remove('gender');
      await prefs.remove('age');
      await prefs.remove('weight');
      await prefs.remove('illnesses');
      await prefs.remove('medications');
      // Clear auth token if you have one
      await prefs.remove('authToken');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully logged out')),
      );

      // Navigate to login screen and clear navigation stack
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }

  // Map OpenWeatherMap icon codes to Material Icons
  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d': // Clear sky (day)
        return Icons.wb_sunny;
      case '01n': // Clear sky (night)
        return Icons.nightlight_round;
      case '02d': // Few clouds (day)
        return Icons.wb_cloudy;
      case '02n': // Few clouds (night)
        return Icons.cloud;
      case '03d': // Scattered clouds (day)
      case '03n': // Scattered clouds (night)
        return Icons.cloud;
      case '04d': // Broken clouds (day)
      case '04n': // Broken clouds (night)
        return Icons.cloud_queue;
      case '09d': // Shower rain (day)
      case '09n': // Shower rain (night)
        return Icons.grain;
      case '10d': // Rain (day)
        return Icons.beach_access; // Day rain with sun
      case '10n': // Rain (night)
        return Icons.nights_stay; // Night rain
      case '11d': // Thunderstorm (day)
      case '11n': // Thunderstorm (night)
        return Icons.flash_on;
      case '13d': // Snow (day)
      case '13n': // Snow (night)
        return Icons.ac_unit;
      case '50d': // Mist (day)
      case '50n': // Mist (night)
        return Icons.foggy;
      default:
        return Icons.help_outline; // Unknown weather
    }
  }

  @override
  Widget build(BuildContext context) {
    // Apply Nunito font to all text widgets
    final textTheme = Theme.of(context).textTheme;
    final nunitoTextTheme = GoogleFonts.nunitoTextTheme(textTheme);

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: nunitoTextTheme,
      ),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/logo.jpg', width: 40, height: 40),
                          const SizedBox(width: 8),
                          Text(
                            'Shams',
                            style: GoogleFonts.nunito(
                              textStyle: Theme.of(context).textTheme.headlineMedium,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Color(0xFFD89E00)),
                        onPressed: () {
                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Log Out',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                'Are you sure you want to log out?',
                                style: GoogleFonts.nunito(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.nunito(),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _logout();
                                  },
                                  child: Text(
                                    'Log Out',
                                    style: GoogleFonts.nunito(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        tooltip: 'Log out',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Color(0xFFD89E00)),
                      const SizedBox(width: 4),
                      Text(
                        city,
                        style: GoogleFonts.nunito(
                          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Color(0xFFD89E00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    currentDay.toUpperCase(),
                    style: GoogleFonts.nunito(
                      textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        temperature,
                        style: GoogleFonts.nunito(
                          textStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 48,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _getWeatherIcon(weatherIcon),
                        color: const Color(0xFFD89E00),
                        size: 48,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Humidity: $humidity',
                        style: GoogleFonts.nunito(
                          textStyle: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        'UV Index: $uvIndex',
                        style: GoogleFonts.nunito(
                          textStyle: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                ..._buildWarnings(),
                _buildWaterTracker(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.health_and_safety,
                                color: Color(0xFFD89E00),
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Health Advice',
                                style: GoogleFonts.nunito(
                                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _isLoadingAdvice
                              ? const Center(child: CircularProgressIndicator())
                              : _adviceList.isEmpty
                              ? Text(
                            'No advice generated yet',
                            style: GoogleFonts.nunito(
                              textStyle: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _adviceList
                                .map((advice) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '•',
                                    style: GoogleFonts.nunito(
                                      textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFFD89E00),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      advice,
                                      style: GoogleFonts.nunito(
                                        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}