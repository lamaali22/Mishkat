// MapWithShortestPath class
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mishkat/services/fayShortestPath/newIndoorGraph.dart';
import 'package:mishkat/services/fayShortestPath/dijkstra.dart';
import 'package:mishkat/services/fayShortestPath/newShortestPath.dart';

class MapWithShortestPath extends StatefulWidget {
  final LatLng userLocation;
  final LatLng tappedLocation;

  const MapWithShortestPath({
    Key? key,
    required this.userLocation,
    required this.tappedLocation,
  }) : super(key: key);

  @override
  _MapWithShortestPathState createState() => _MapWithShortestPathState();

}

class _MapWithShortestPathState extends State<MapWithShortestPath> {
  Set<String> shortestPath = {};

  @override
  void initState() {
    super.initState();
    print('before call shortestPath');
    calculateShortestPath();
    print('called shortestPath');
  }

Future<void> calculateShortestPath() async {
  Set<String> calculatedShortestPath = await ShortestPath.calculateShortestPath(
    widget.userLocation,
    widget.tappedLocation,
  );
  setState(() {
    shortestPath = calculatedShortestPath;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map with Shortest Path'),
      ),
      body: FlutterMap(
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
          PolylineLayer(
            polylines: [
              Polyline(
                points: shortestPath.map((nodeId) {
                  final node =ShortestPath.roomGraph.nodes[nodeId];
                  print('node is ${node?.coordinates}');
                  return LatLng(node!.coordinates[1], node.coordinates[0]);
                }).toList(),
                color: Colors.blue,
                strokeWidth: 3.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
