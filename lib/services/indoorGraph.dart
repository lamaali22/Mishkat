import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

class IndoorGraph {
  Map<String, LatLng> nodes;
  Map<String, List<String>> connections;

  IndoorGraph(this.nodes, this.connections);

  void addNode(String id, LatLng coordinates) {
    nodes[id] = coordinates;
  }

  void addConnection(String fromNode, String toNode) {
    if (!connections.containsKey(fromNode)) {
      connections[fromNode] = [];
    }
    connections[fromNode]!.add(toNode);
  }
}

class DijkstraResult {
  final Map<String, double> distances;
  final Map<String, String?> previousNodes;

  DijkstraResult(this.distances, this.previousNodes);
}

DijkstraResult dijkstra(IndoorGraph graph, String start, String end) {
  Set<String> unvisited = Set<String>.from(graph.nodes.keys);
  Map<String, double> distances = {};
  Map<String, String?> previous = {};

  for (var node in graph.nodes.keys) {
    distances[node] = double.infinity;
  }

  distances[start] = 0;

  while (unvisited.isNotEmpty) {
    String current = _getClosestNode(unvisited, distances);
    unvisited.remove(current);

    for (var neighbor in graph.connections[current] ?? []) {
      double alt = distances[current]! + _calculateDistance(current, neighbor, graph);

      if (alt < distances[neighbor]!) {
        distances[neighbor] = alt;
        previous[neighbor] = current;
      }
    }
  }

  List<String> path = [];
  String? current = end;

  while (current != start) {
    path.add(current!);
    current = previous[current!];
  }

  path.add(start);
  path = path.reversed.toList();

  return DijkstraResult(distances, previous);
}

String _getClosestNode(Set<String> unvisited, Map<String, double> distances) {
  String closestNode = unvisited.first;
  for (var node in unvisited) {
    if (distances[node]! < distances[closestNode]!) {
      closestNode = node;
    }
  }
  return closestNode;
}

double degreesToRadians(double degrees) {
  return degrees * math.pi / 180;
}

double _calculateDistance(String start, String end, IndoorGraph graph) {
  LatLng startLatLng = graph.nodes[start]!;
  LatLng endLatLng = graph.nodes[end]!;

  double lat1 = startLatLng.latitude;
  double lon1 = startLatLng.longitude;
  double lat2 = endLatLng.latitude;
  double lon2 = endLatLng.longitude;

  const R = 6371;

  double dLat = degreesToRadians(lat2 - lat1);
  double dLon = degreesToRadians(lon2 - lon1);

  double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(degreesToRadians(lat1)) * math.cos(degreesToRadians(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);

  double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return R * c;
}
