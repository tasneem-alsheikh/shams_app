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

 Future<String> _fetchCDCContent(SharedPreferences prefs) async {
    final List<String> userConditions =
        prefs.getStringList('illnesses')?.map((e) => e.toLowerCase()).toList() ?? [];
    final List<String> userMedications =
        prefs.getStringList('medications')?.map((e) => e.toLowerCase()).toList() ?? [];
    final String ageStr = prefs.getString('age') ?? '';
    final int age = int.tryParse(ageStr) ?? 0;

    // Map user condition keywords to CDC URLs
    final conditionUrlMap = {
      'heart disease': 'https://www.cdc.gov/heat-health/hcp/toolkits/toolkit-for-people-with-heart-disease.html',
      'asthma': 'https://www.cdc.gov/heat-health/hcp/toolkits/tips-and-action-plans-for-children-with-asthma.html',
      'pregnancy': 'https://www.cdc.gov/heat-health/risk-factors/heat-and-pregnancy.html',
      'chronic conditions': 'https://www.cdc.gov/heat-health/risk-factors/heat-and-chronic-conditions.html',
      'older adults': 'https://www.cdc.gov/heat-health/risk-factors/heat-and-older-adults-aged-65.html',
      'children': 'https://www.cdc.gov/heat-health/risk-factors/infants-and-children.html',
      'medications': 'https://www.cdc.gov/heat-health/hcp/clinical-guidance/heat-and-medications-guidance-for-clinicians.html',
    };

    // Conditions that count as chronic
    final chronicConditions = [
      'stroke',
      'strokes',
      'copd',
      'diabetes',
      'thyroid disorders',
      'epilepsy',
      'parkinson’s disease',
      'multiple sclerosis',
      'lupus',
      'vitiligo',
      'psoriasis',
      'chronic kidney disease',
      'overweight',
      'obesity',
    ];

    final heatSensitiveMedications = [
      'diuretics',
      'blood pressure medications',
      'psychiatric medications',
      'diabetes medications',
      'neurological medications',
      'allergy medications',
      'hormonal medications',
    ];

    // Determine which URLs to include
    final Set<String> matchedKeys = {};

    for (final condition in userConditions) {
      if (condition.contains('heart')) matchedKeys.add('heart disease');
      if (condition.contains('asthma')) matchedKeys.add('asthma');
      if (condition.contains('pregnan')) matchedKeys.add('pregnancy');
      if (chronicConditions.contains(condition)) matchedKeys.add('chronic conditions');
      if (condition.contains('child')) matchedKeys.add('children');
    }

    // Age-based rule
    if (age >= 65) {
      matchedKeys.add('older adults');
    } else if (age <= 12) {
      matchedKeys.add('children');
    }

    // Medication-based rule
    if (userMedications.any((med) => heatSensitiveMedications.contains(med))) {
      matchedKeys.add('medications');
    }

    // Build URL map for relevant keys only
    final urls = {
      for (var key in matchedKeys) key[0].toUpperCase() + key.substring(1): conditionUrlMap[key]!
    };

    final client = http.Client();
    final buffer = StringBuffer();

    try {
      for (var entry in urls.entries) {
        final response = await client.get(Uri.parse(entry.value));
        if (response.statusCode == 200) {
          final raw = response.body;

          // Extract <main> content
          final mainContentMatch = RegExp(r'<main[^>]*>(.*?)<\/main>', dotAll: true).firstMatch(raw);
          String cleaned = mainContentMatch?.group(1) ?? raw;

          // Strip tags & format bullets
          cleaned = cleaned
              .replaceAll(RegExp(r'<(script|style)[^>]*>.*?</\1>', dotAll: true), '')
              .replaceAllMapped(RegExp(r'<li>(.*?)<\/li>', dotAll: true), (match) => '\n• ${match.group(1)}')
              .replaceAll(RegExp(r'<[^>]+>'), ' ')
              .replaceAll('&nbsp;', ' ')
              .replaceAll(RegExp(r'\s{2,}'), ' ')
              .trim();

          buffer.writeln('### ${entry.key} Guidelines:\n');
          buffer.writeln(cleaned.substring(0, cleaned.length > 1800 ? 1800 : cleaned.length));
          buffer.writeln('\n\n');
        }
      }

      return buffer.isEmpty ? 'No specific CDC guidance matched your health profile.' : buffer.toString();
    } catch (e) {
      debugPrint('Error fetching CDC content: $e');
      return 'CDC content unavailable';
    } finally {
      client.close();
    }
  }

  // Updated API call function with RAG integration
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
              'content': '''You are a medical assistant. Follow these rules:
            1. Base recommendations STRICTLY on CDC guidelines
            2. Provide EXACTLY 5 bullet points
            3. Each point must be 1-2 lines
            4. No explanations or disclaimers
            5. Make advice specific and actionable'''
            },
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.3, // Lower for more factual responses
        }),
      ).timeout(const Duration(seconds: 15));

      final Map<String, dynamic> data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'] as String? ?? '';
      debugPrint('Mistral raw response: $content');
      return content.split('\n')
          .where((line) => line.trim().isNotEmpty)
          .where((line) => line.trim().isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('API Error: $e');
      return [
        '1. Drink at least 8 glasses of water today',
        '2. Avoid prolonged sun exposure between 10AM-4PM',
        '3. Wear lightweight, loose-fitting clothing'
      ];
    }
  }

  // Updated advice generation with CDC context
  Future<void> _generatePersonalizedAdvice() async {
    setState(() => _isLoadingAdvice = true);

    final prefs = await SharedPreferences.getInstance();
    try {
      final cdcContent = await _fetchCDCContent(prefs);

      final userData = {
        'age': prefs.getString('age') ?? 'Unknown',
        'conditions': prefs.getStringList('illnesses')?.join(", ") ?? "None",
        'medications': prefs.getStringList('medications')?.join(", ") ?? "None",
        'weather': '$temperature, UV $uvIndex, $humidity% humidity'
      };

      final prompt = """
      You are a health assistant.
      
      The following is content extractred directly from CDC heat-related illness pages. Use it to generate personalized advice.
      
      ### CDC Guidelines (Structured Snippets)
      $cdcContent
      
      ### User Profile:
      - Age: ${userData['age']}
      - Conditions: ${userData['conditions']}
      - Medications: ${userData['medications']}
      - Current Weather: ${userData['weather']}
      
      ### Your Task:
      Based strictly on CDC guidance above (so don't deviate from it) and considering the user's profile, return 5 concise, specific recommendations:
      - 1–2 lines per bullet
      - Actionable (e.g. exact quantity, time, or clothing advice)
      - No explanation or disclaimers
      - No mention of data values (e.g. "UV index" or "temperature")
      - Must be medically sound and grounded in the guidelines
      -Avoid general tips unless critical to conditon
      """;

      debugPrint(prompt);
      _adviceList = await _callMistralAPI(prompt);
    } catch (e) {
      _adviceList = [
        '1. Stay hydrated with water throughout the day',
        '2. Limit outdoor activity during peak heat',
        '3. Check on vulnerable individuals'
      ];
      debugPrint('Advice generation error: $e');
    } finally {
      setState(() => _isLoadingAdvice = false);
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
