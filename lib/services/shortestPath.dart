import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mishkat/services/indoorGraph.dart';
import 'dart:math' as math;

class ShortestPath {
  static RoomGraph roomGraph = RoomGraph();

  static Future<Set<String>> calculateShortestPath(
    LatLng userLocation,
    LatLng tappedLocation,
  ) async {
    String startRoomId = findNearestRoom(userLocation, roomGraph);
    String endRoomId = findNearestRoom(tappedLocation, roomGraph);
print('startRoomId is $startRoomId');
print('endRoomId is $tappedLocation');

    Map<String, double> distances = roomGraph.dijkstra(startRoomId);
    Set<String> shortestPath = {};
    String currentRoomId = endRoomId;

print('distances are ${distances.entries}');

    while (currentRoomId != startRoomId) {
      shortestPath.add(currentRoomId);
      currentRoomId = findPreviousRoom(currentRoomId, distances, roomGraph);
    }

    shortestPath.add(startRoomId);
print('shortest path is ${shortestPath.length}');
    return shortestPath;
  }

  

  static String findNearestRoom(LatLng point, RoomGraph roomGraph) {
    double minDistance = double.infinity;
    String nearestRoomId = '';

    roomGraph.nodes.forEach((roomId, node) {
      double distance = calculateDistance(point, LatLng(node.coordinates[1], node.coordinates[0]));

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
      String start = edge.start;
      String end = edge.end;
      double weight = edge.weight;

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
}
