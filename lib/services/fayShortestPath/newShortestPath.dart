import 'package:latlong2/latlong.dart';
import 'package:mishkat/services/fayShortestPath/newIndoorGraph.dart';

class ShortestPath {
  static IndoorGraph indoorGraph = IndoorGraph(); // Initialize with your GeoJSON data

  static Future<Set<String>> calculateShortestPath(
    LatLng userLocation,
    LatLng tappedLocation,
  ) async {
    // Assume that findNearestNode is implemented in the IndoorGraph class
    String startNodeId = findNearestNode(userLocation);
    String endNodeId = findNearestNode(tappedLocation);
    print('start node $startNodeId');

    Set<String> shortestPath = await findShortestPath(startNodeId, endNodeId);

    print('shortestPath is $shortestPath');
    return shortestPath;
  }

    static Future<Set<String>> findShortestPath(
      String startNodeId,
      String endNodeId,
    ) async {
      var result = indoorGraph.dijkstra(startNodeId);
      Map<String, double> distances = result['distances'] as Map<String, double>;
      Map<String, String> previous = result['previous'] as Map<String, String>;

      // Reconstruct the shortest path from endNodeId to startNodeId
      Set<String> shortestPath = {};
      String currentRoomId = endNodeId;
      while (currentRoomId != startNodeId) {
        shortestPath.add(currentRoomId);
        currentRoomId = previous[currentRoomId] ?? startNodeId; // Fallback to startNodeId if no previous node found
      }
      shortestPath.add(startNodeId); // Add the start node to the path

    // Print the shortest path
      print("Shortest path from $startNodeId to $endNodeId: ${shortestPath.toList().reversed.join(' -> ')}");

      return shortestPath;
    }

    static String findNearestNode(LatLng location) {
    String nearestNodeId = '';
    double nearestDistance = double.infinity;

    indoorGraph.nodeCenters.forEach((nodeId, center) {
      double distance = _calculateDistance(location, center);
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestNodeId = nodeId;
      }
    });

    return nearestNodeId;
  }

  static double _calculateDistance(LatLng start, List<double> end) {
    final Distance distance = Distance();
    return distance.as(
      LengthUnit.Meter,
      LatLng(start.latitude, start.longitude),
      LatLng(end[1], end[0]), // Note: GeoJSON uses [longitude, latitude]
    );
  }

}

