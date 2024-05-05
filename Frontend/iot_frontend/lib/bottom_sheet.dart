import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/io.dart';

class DeviceData {
  final String deviceId; // Change type to String
  final double latitude;
  final double longitude;
  final double decisionValue;

  DeviceData({
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    required this.decisionValue,
  });
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State {
  List<DeviceData> deviceDataList = [];
  Position? _currentPosition;
  List<Map<String, double>> latLongList = [];


  @override
  void initState() {
    super.initState();
    connectToWebSocket();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  String _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const int earthRadius = 6371; // in kilometers

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = pow(sin(dLat / 2), 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) * pow(sin(dLon / 2), 2);
    double c = 2 * asin(sqrt(a));
    double distance = earthRadius * c;

    return distance.toStringAsFixed(2); // Return distance rounded to 2 decimal places
  }

  void connectToWebSocket() {
    final channel = IOWebSocketChannel.connect('ws://192.168.187.238:3000');
    channel.stream.listen((message) {
      print('Received message: $message');
      try {
        final List<dynamic> parsedDataList = jsonDecode(message);
        print('Parsed data: $parsedDataList');
        setState(() {
          // Clear existing device data list
          deviceDataList.clear();

          // Iterate over each device data object in the parsed list
          parsedDataList.forEach((parsedData) {
            deviceDataList.add(DeviceData(
              deviceId: parsedData['deviceId'], // Direct assignment, no need for toString()
              latitude: parsedData['location'][0].toDouble(),
              longitude: parsedData['location'][1].toDouble(),
              decisionValue: parsedData['decision_value'].toDouble(),
            ));
            latLongList.add({
              'latitude': parsedData['location'][0].toDouble(),
              'longitude': parsedData['location'][1].toDouble(),
            });
          });

        });
      } catch (e) {
        print('Error parsing message: $e');
      }
    }, onError: (error) {
      print('WebSocket error: $error');
    }, onDone: () {
      print('WebSocket connection closed');
    });
  }


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: deviceDataList.length,
      itemBuilder: (context, index) {
        String availabilityText;
        final deviceData = deviceDataList[index];

        if (deviceData.decisionValue >= 20) {
          availabilityText = 'Available';
        } else {
          availabilityText = 'Unvailable';
        }

        // Calculate distance if current position is available
        String distanceText = '';
        if (_currentPosition != null) {
          double distance = double.parse(_calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            deviceData.latitude,
            deviceData.longitude,
          ));
          distanceText = '${distance.toStringAsFixed(2)} km';
        }

        return Card(
          child: ListTile(
            title: Text('Parking Zone: ${deviceData.deviceId}'),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Distance from you: '),
                        SizedBox(width: 5),
                        Text(distanceText, style: TextStyle(color: Color(0xFF1924FF)),),
                      ],
                    ), // Display distance
                    Row(
                      children: [
                        Text('Availability: '),
                        SizedBox(width: 5),
                        Text(
                          availabilityText,
                          style: TextStyle(
                            color: availabilityText == 'Available' ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: availabilityText == 'Available' ? () {
                    // Add your onPressed logic here
                  } : null, // Set onPressed to null if availability is false
                  style: availabilityText == 'Available' ? null : ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.grey), // Change color to grey if not available
                  ),
                  child: Text("Park Here"),
                )

              ],
            ),
          ),
        );
      },
    );
  }
}
