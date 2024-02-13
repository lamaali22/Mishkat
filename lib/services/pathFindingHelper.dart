// import 'package:dijkstra/dijkstra.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:mishkat/services/IndoorGraph.dart';

// class Pathfinding {
//   static List<LatLng> calculateShortestPath(IndoorGraph graph, String start, String end) {
//     DijkstraResult result = Dijkstra.dijkstra(graph, start, end);

//     // Reconstruct the shortest path
//     List<LatLng> path = [];
//     String? current = end;

//     while (current != start) {
//       path.add(graph.nodes[current!]!);
//       current = result.previousNodes[current!];
//     }

//     path.add(graph.nodes[start]!);
//     path = path.reversed.toList();

//     return path;
//   }
// }
