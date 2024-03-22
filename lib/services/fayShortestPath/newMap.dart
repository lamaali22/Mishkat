import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mishkat/services/fayShortestPath/newIndoorGraph.dart';
import 'package:mishkat/services/fayShortestPath/newShortestPath.dart';

class MapWithShortestPath extends StatefulWidget {
  final LatLng userLocation;
  final LatLng tappedLocation;
  // final Map<String, dynamic> geoJsonData;

  const MapWithShortestPath({
    Key? key,
    required this.userLocation,
    required this.tappedLocation,
    // required this.geoJsonData,
  }) : super(key: key);

  @override
  _MapWithShortestPathState createState() => _MapWithShortestPathState();
}

class _MapWithShortestPathState extends State<MapWithShortestPath> {
  Set<String> shortestPath = {};
  List<LatLng> pathCoordinates = [];
  List<Polygon> polygons = [];
  List<Marker> polygonLabels = [];
  MapController mapController=MapController();

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
    calculateShortestPath();
  }

  Future<void> _loadGeoJson() async {
    final geoJsonString =
        await DefaultAssetBundle.of(context).loadString('assets/map.geojson');
    final geoJson = json.decode(geoJsonString);

    _convertAndDisplayPolygons(geoJson);
  }


  Future<void> calculateShortestPath() async {
    Set<String> calculatedShortestPath = await ShortestPath.calculateShortestPath(
      widget.userLocation,
      widget.tappedLocation,
    );
    setState(() {
      shortestPath = calculatedShortestPath;
      print('shortestPath newMap $shortestPath');
      
      pathCoordinates = shortestPath.map((nodeId) {
        final nodeCenter = ShortestPath.indoorGraph.getNodeCenter(nodeId);
        return LatLng(nodeCenter[1], nodeCenter[0]);
      }).toList();
      print('pathCoordinates $pathCoordinates');
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map with Shortest Path'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: LatLng(
            (widget.userLocation.latitude + widget.tappedLocation.latitude) / 2,
            (widget.userLocation.longitude + widget.tappedLocation.longitude) / 2,
          ),
          zoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          PolygonLayer(polygons: polygons),
          MarkerLayer(markers: polygonLabels),
          PolylineLayer(
            polylines: [
              Polyline(
                points: pathCoordinates,
                color: Colors.blue,
                strokeWidth: 3.0,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: widget.userLocation,
                builder: (ctx) => Icon(Icons.location_pin, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _convertAndDisplayPolygons(Map<String, dynamic> geoJson) async {
    for (var feature in geoJson['features']) {
      if (feature['geometry']['type'] == 'Polygon') {
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
            color: fillColor.withOpacity(0.5),
            borderStrokeWidth: 1,
            borderColor: strokeColor,
            isDotted: false,
          ));
        });
        LatLng calculateAveragePosition(List<LatLng> coordinates) {
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

        if (feature['properties']['roomId'] != null && feature['properties']['type'] != null && feature['geometry']['type'] == "Polygon") { // additional checks to avoid 'LineString'
          LatLng labelPosition = calculateAveragePosition(coordinates);
          // Get a reference to the Firestore document
          String roomId = feature['properties']['roomId'];
          String type = feature['properties']['type'];
          // this code might be used later

          // if (type == "classroom" ||
          //     type == "mariah auditorium" ||
          //     type == "khadijah auditorium")
          //   await _updateClassroomCoordinates(roomId, labelPosition);

          // if (type == "lab") await _updateLabCoordinates(roomId, labelPosition);
          // if (type == "office")
          //   await _updateOfficeCoordinates(roomId, labelPosition);
          // if (type != "classroom" &&
          //     type != "mariah auditorium" &&
          //     type != "khadijah auditorium" &&
          //     type != "lab")
          //   await _updateServiceCoordinates(roomId, labelPosition);

          if (type == 'service') {
            try {
              // Query Firestore to get serviceName
              DocumentSnapshot snapshot = await FirebaseFirestore.instance
                  .collection('Services')
                  .doc(roomId)
                  .get();

              // Check if the document exists
              if (snapshot.exists) {
                String serviceName = snapshot['serviceName'];
                // Update the label property based on serviceName
                feature['properties']['label'] = serviceName;
              } else {
                // Handle the case when the document does not exist
                print('Document does not exist');
              }
            } catch (e) {
              // Handle errors while fetching data
              print('Error fetching data: $e');
            }
          }



          setState(() {
            // Add Marker for label
            polygonLabels.add(
              Marker(
                  point: labelPosition,
                  builder: (ctx) => GestureDetector(
                        onTap: () {
                         
                        },
                        child: Transform.scale(
                          scale: 0.08 * mapController.zoom,
                          child: Transform.translate(
                            //11goes down and the 3 left and right
                            offset: const Offset(10.0, 2),
                            child: Transform.rotate(
                              angle: -pi / 2,
                              child: Column(
                                children: [
                                  if (feature['properties']['icon'] != null)
                                    Image.network(
                                      feature['properties']['icon'],
                                      height: 13,
                                      width: 13,
                                    ),
                                  Text(
                                    feature['properties']['label'] ?? '',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 5.0,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )),
            );
          });
        }
      }
    }

  }

    Color _parseColor(String colorString) {
    if (colorString.length == 7 && colorString.startsWith('#')) {
      return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
    } else {
      return Colors.transparent;
    }
  }
}