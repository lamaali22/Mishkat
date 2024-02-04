import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Map Demo',
      home: MapScreen(title: 'Flutter Map Demo'),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController mapController;
  List<Polygon> polygons;
  List<Marker> polygonLabels;

  _MapScreenState()
      : mapController = MapController(),
        polygons = [],
        polygonLabels = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            center: LatLng(24.72337, 46.63664),
            minZoom: 14.0,
            zoom: 19,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            GestureDetector(
              child: PolygonLayer(
                polygons: polygons,
              ),
            ),
            MarkerLayer(markers: polygonLabels),
          ],
        ),
      ),
    );
  }

  Future<void> _loadGeoJson() async {
    final geoJsonString =
        await DefaultAssetBundle.of(context).loadString('assets/map.geojson');
    final geoJson = json.decode(geoJsonString);

    _convertAndDisplayPolygons(geoJson);
  }

  void _convertAndDisplayPolygons(Map<String, dynamic> geoJson) {
    for (var feature in geoJson['features']) {
      if (feature['geometry']['type'] == 'Polygon') {
        // ... existing code ...
        List<LatLng> coordinates = [];

        for (var point in feature['geometry']['coordinates'][0]) {
          coordinates.add(LatLng(point[1], point[0]));
        }

        Color fillColor = _parseColor(feature['properties']['fill']);
        Color strokeColor = _parseColor(feature['properties']['stroke']);

        // Add Polygon
        setState(() {
          polygons.add(Polygon(
            points: coordinates,
            isFilled: true,
            color: fillColor,
            borderStrokeWidth: 1,
            borderColor: strokeColor,
            isDotted: false,
          ));
        });
        LatLng _calculateAveragePosition(List<LatLng> coordinates) {
          double sumLat = 0.0;
          double sumLng = 0.0;

          for (var coord in coordinates) {
            sumLat += coord.latitude;
            sumLng += coord.longitude;
          }

          double avgLat = sumLat / coordinates.length;
          double avgLng = sumLng / coordinates.length;

          return LatLng(avgLat, avgLng);
        }

        // Add Polygon Label
        if (feature['properties']['roomId'] != null) {
          LatLng labelPosition = _calculateAveragePosition(coordinates);

          setState(() {
            // Add Marker for label
            polygonLabels.add(Marker(
              point: labelPosition,
              builder: (ctx) => GestureDetector(
                onTap: () {
                  // Handle tap on the label
                  _handleLabelTap(feature['properties']['roomId']);
                },
                child: Transform.translate(
                  offset: Offset(9.0, 1.0),
                  child: Transform.rotate(
                    angle: -pi / 2,
                    child: Column(
                      children: [
                        // if (feature['properties']['icon'] != null)
                        //   Image.network(
                        //     feature['properties']['icon'],
                        //     height: 11,
                        //     width: 11,
                        //   ),

                        if (feature['properties']['icon'] ==
                            "https://cdn-icons-png.flaticon.com/512/1057/1057624.png")
                          Image.network(
                            feature['properties']['icon'],
                            height: 11,
                            width: 11,
                          ),
                        if (feature['properties']['icon'] ==
                            "https://cdn-icons-png.flaticon.com/512/6131/6131013.png")
                          Image.network(
                            feature['properties']['icon'],
                            height: 11,
                            width: 11,
                          ),
                        if (feature['properties']['icon'] ==
                            "https://cdn-icons-png.flaticon.com/512/10997/10997170.png")
                          Image.network(
                            feature['properties']['icon'],
                            height: 11,
                            width: 11,
                          ),
                        if (feature['properties']['icon'] ==
                            "https://cdn-icons-png.freepik.com/256/4994/4994427.png")
                          Image.network(
                            feature['properties']['icon'],
                            height: 11,
                            width: 11,
                          ),
//if(feature['properties']['type']=="service")
                        Text(
                          feature['properties']['label'] ?? '',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 8.0,
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ));
          });
        }
      }
    }
  }

  void _handleLabelTap(String roomId) {
    // Handle tap on the label here
    print('Room ID tapped: $roomId');
  }

  Color _parseColor(String colorString) {
    // Check if the color string is in the valid format
    if (colorString.length == 7 && colorString.startsWith('#')) {
      return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
    } else {
      // Default color if the format is not valid
      return Colors.transparent;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }
}
