// import 'dart:math' as math;
// import 'package:latlong2/latlong.dart';
// import 'package:mishkat/services/IndoorGraph.dart';

// class Node implements Comparable<Node> {
//   final String id;
//   final double distance;

//   Node(this.id, this.distance);

//   @override
//   int compareTo(Node other) => distance.compareTo(other.distance);
// }

// class PriorityQueue<T extends Node> {
//   final List<_PriorityQueueItem<T>> _items = [];

//   void add(T item) {
//     _items.add(_PriorityQueueItem<T>(item, item.distance));
//     _items.sort((a, b) => a.priority.compareTo(b.priority));
//   }

//   T removeFirst() {
//     if (_items.isEmpty) {
//       throw StateError('PriorityQueue is empty');
//     }

//     return _items.removeAt(0).item;
//   }

//   bool get isNotEmpty => _items.isNotEmpty;
// }

// class _PriorityQueueItem<T extends Node> {
//   final T item;
//   final double priority;

//   _PriorityQueueItem(this.item, this.priority);
// }

// class DijkstraResult {
//   final Map<String, double> distances;
//   final Map<String, String?> previousNodes;

//   DijkstraResult(this.distances, this.previousNodes);
// }

// class Dijkstra {
//   static DijkstraResult dijkstra(IndoorGraph graph, String start, String end) {
//     Set<String> unvisited = Set<String>.from(graph.nodes.keys);
//     Map<String, double> distances = {};
//     Map<String, String?> previous = {};

//     for (var node in graph.nodes.keys) {
//       distances[node] = double.infinity;
//     }

//     distances[start] = 0;

//     while (unvisited.isNotEmpty) {
//       String current = _getClosestNode(unvisited, distances);
//       unvisited.remove(current);

//       for (var neighbor in graph.connections[current] ?? []) {
//         double alt = distances[current]! + _calculateDistance(current, neighbor, graph);

//         if (alt < distances[neighbor]!) {
//           distances[neighbor] = alt;
//           previous[neighbor] = current;
//         }
//       }
//     }

//     return DijkstraResult(distances, previous);
//   }

//   static String _getClosestNode(Set<String> unvisited, Map<String, double> distances) {
//     String closestNode = unvisited.first;
//     for (var node in unvisited) {
//       if (distances[node]! < distances[closestNode]!) {
//         closestNode = node;
//       }
//     }
//     return closestNode;
//   }

//   static double _calculateDistance(String start, String end, IndoorGraph graph) {
//     LatLng startLatLng = graph.nodes[start]!;
//     LatLng endLatLng = graph.nodes[end]!;

//     double lat1 = startLatLng.latitude;
//     double lon1 = startLatLng.longitude;
//     double lat2 = endLatLng.latitude;
//     double lon2 = endLatLng.longitude;

//     const double R = 6371;

//     double dLat = _degreesToRadians(lat2 - lat1);
//     double dLon = _degreesToRadians(lon2 - lon1);

//     double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
//         math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);

//     double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

//     return R * c;
//   }

//   static double _degreesToRadians(double degrees) {
//     return degrees * math.pi / 180;
//   }
// }
