
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mishkat/services/indoorGraph.dart';
import 'dart:math' as math;

class ShortestPath {
  static RoomGraph roomGraph = RoomGraph();

  static Future<List<LatLng>> calculateShortestPath(
    LatLng userLocation,
    LatLng tappedLocation,
    
  ) async {
    String startRoomId = '6G47';
    //findNearestRoom(userLocation, roomGraph);
    String endRoomId = '6G51';
    // findNearestRoom(tappedLocation, roomGraph);
print('start room is $startRoomId');
print('end room is $endRoomId');

    Map<String, double> distances = roomGraph.dijkstra(startRoomId);

    List<LatLng> shortestPath = [];
    String currentRoomId = endRoomId;

    while (currentRoomId != startRoomId) {
      RoomNode currentNode = roomGraph.nodes[currentRoomId]!;
      shortestPath.add(LatLng(currentNode.coordinates[1], currentNode.coordinates[0]));

      currentRoomId = findPreviousRoom(currentRoomId, distances, roomGraph);
    }

    shortestPath.add(userLocation);
    shortestPath = shortestPath.reversed.toList(); // Reverse the path
print('shortest path is ${ShortestPath.roomGraph.nodes}');
    return shortestPath;
  }

  static String findNearestRoom(LatLng point, RoomGraph roomGraph) {
    double minDistance = double.infinity;
    String nearestRoomId = '';

    roomGraph.nodes.forEach((roomId, node) {
      double distance = calculateDistance(point, LatLng(node.coordinates[1], node.coordinates[0]));
print('distance is $distance');
      if (distance < minDistance) {
        minDistance = distance;
        nearestRoomId = roomId;
      }
    });

    return nearestRoomId;
  }

  static String findPreviousRoom(
    String currentRoomId,
    Map<String, double> distances,
    RoomGraph roomGraph,
  ) {
    double currentDistance = distances[currentRoomId]!;
    String previousRoomId = currentRoomId;

    roomGraph.edges.forEach((edge) {
      String start = edge.elementAt(0);
      String end = edge.elementAt(1);
      double weight = edge.elementAt(2);

      if (end == currentRoomId) {
        double totalDistance = currentDistance - weight;
        if (totalDistance == distances[start]) {
          previousRoomId = start;
        }
      }
    });

    return previousRoomId;
  }

 
  static double calculateDistance(LatLng point1, LatLng point2) {
    const R = 6371000.0; // Radius of the Earth in meters

    double lat1 = degreesToRadians(point1.latitude);
    double lon1 = degreesToRadians(point1.longitude);
    double lat2 = degreesToRadians(point2.latitude);
    double lon2 = degreesToRadians(point2.longitude);

    double dlat = lat2 - lat1;
    double dlon = lon2 - lon1;

    double a = math.pow(math.sin(dlat / 2), 2) +
        math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dlon / 2), 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    double distance = R * c;

    return distance;
  }

 static double degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  static List<Polyline> getPolylines(List<LatLng> pathPoints) {
    List<Polyline> polylines = [];

    if (pathPoints.length > 1) {
      List<LatLng> polylineCoordinates = pathPoints;
      Polyline polyline = Polyline(
        points: polylineCoordinates,
        color: Color.fromARGB(66, 245, 0, 204),
        strokeWidth: 4,
      );
      polylines.add(polyline);
    }

    return polylines;
  }
}