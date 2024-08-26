import 'package:clima_actu/class/clima.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Weather> futureWeather;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar el clima inicial para 'Honduras'
    futureWeather = fetchWeather('Honduras');
  }

  Future<Weather> fetchWeather(String country) async {
    final response = await http.get(Uri.parse(
        'http://api.weatherapi.com/v1/current.json?key=d292b9353698419c8ff20654242608&q=$country&aqi=yes'));

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar el clima');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte del Clima'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Escribe una ciudad',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  // Actualizar el clima al presionar el botón
                  futureWeather = fetchWeather(_controller.text);
                });
              },
              icon: const Icon(Icons.search),
              label: const Text('Buscar'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<Weather>(
                future: futureWeather,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    return _buildWeatherCard(snapshot.data!);
                  } else {
                    return const Center(child: Text('Introduce una ciudad válida.'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(Weather weather) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red, size: 30),
              title: Text(
                'Ubicación: ${weather.location.name}, ${weather.location.region}, ${weather.location.country}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            ListTile(
              leading: Icon(Icons.thermostat_outlined, color: Colors.blue, size: 30),
              title: Text('Temperatura: ${weather.current.tempC}°C',
                  style: const TextStyle(fontSize: 18)),
            ),
            ListTile(
              leading: Icon(
                getWeatherIcon(weather.current.condition.text),
                color: getConditionColor(weather.current.condition.text),
                size: 30,
              ),
              title: Text(
                'Condición: ${weather.current.condition.text}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.air, size: 30),
              title: Text(
                'Viento: ${weather.current.windKph} kph',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.access_time, size: 30),
              title: Text(
                'Hora: ${TimeOfDay.fromDateTime(DateTime.now()).format(context)}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData getWeatherIcon(String condition) {
    if (condition.toLowerCase().contains('sunny')) {
      return Icons.wb_sunny;
    } else if (condition.toLowerCase().contains('cloudy')) {
      return Icons.cloud;
    } else if (condition.toLowerCase().contains('rain')) {
      return Icons.grain;
    } else {
      return Icons.wb_cloudy;
    }
  }

  Color getConditionColor(String condition) {
    if (condition.toLowerCase().contains('sunny')) {
      return Colors.yellow;
    } else if (condition.toLowerCase().contains('cloudy')) {
      return Colors.grey;
    } else if (condition.toLowerCase().contains('rain')) {
      return Colors.blue;
    } else {
      return Colors.black;
    }
  }
}
