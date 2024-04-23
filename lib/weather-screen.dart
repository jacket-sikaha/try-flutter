import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:a/weather-item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> Weather;
  Future<Map<String, dynamic>> getWeather() async {
    var city = 'foshan';
    var apikey = '98ede99d830b8613593646c471a217f4';
    var apiUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apikey');
    try {
      // 发送 GET 请求
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        // 请求成功，处理响应数据
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw '请求 failure';
      }
    } catch (error) {
      // 捕获异常错误
      print('发生异常错误：$error');
      throw error.toString();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Weather = getWeather();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather app',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // GestureDetector(
          //   child: const Icon(Icons.refresh),
          //   onTap: () {
          //     print('refresh');
          //   },
          // )
          IconButton(
              onPressed: () {
                setState(() {
                  // 这里只会重建与weather状态相关的组件
                  Weather = getWeather();
                }); // 重建整个app
                print('refresh');
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
        future: Weather,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData['main']['temp'];
          final currentsky = currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentwindspeed = currentWeatherData['wind']['speed'];
          final currenthumidity = currentWeatherData['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              '$currentTemp k',
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Icon(
                              currentsky == 'Clouds' || currentsky == 'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                              size: 64,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(currentsky,
                                style: const TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'weather forecast',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 8,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    for (int i = 0; i < 25; i++)
                      HourlyForecastItem(
                        time: data['list'][i + 1]['dt'].toString(),
                        icon: data['list'][i + 1]['weather'][0]['main'] ==
                                    'Clouds' ||
                                data['list'][i + 1]['weather'][0]['main'] ==
                                    'Rain'
                            ? Icons.cloud
                            : Icons.sunny,
                        temperature:
                            data['list'][i + 1]['main']['temp'].toString(),
                      ),
                  ]),
                ),
                // 采用自带list组件
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                      itemCount: 12,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final HourlyForecast = data['list'][index + 1];
                        final HourlyForecastsky =
                            HourlyForecast['weather'][0]['main'];
                        final HourlyForecasttemp =
                            HourlyForecast['main']['temp'].toString();
                        final time = DateTime.parse(HourlyForecast['dt_txt']);
                        return HourlyForecastItem(
                          time: DateFormat.j().format(time),
                          icon: HourlyForecastsky == 'Clouds' ||
                                  HourlyForecastsky == 'Rain'
                              ? Icons.cloud
                              : Icons.sunny,
                          temperature: HourlyForecasttemp,
                        );
                      }),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'additional information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInformationItem(
                      icon: Icons.water_drop,
                      label: 'humditiy',
                      value: currenthumidity.toString(),
                    ),
                    AdditionalInformationItem(
                      icon: Icons.air,
                      label: 'wind speed',
                      value: currentwindspeed.toString(),
                    ),
                    AdditionalInformationItem(
                      icon: Icons.beach_access,
                      label: 'pressure',
                      value: currentPressure.toString(),
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
