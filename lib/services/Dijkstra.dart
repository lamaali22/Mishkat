// import 'dart:collection';
// import 'package:collection/priority_queue.dart';
// import 'package:latlong2/latlong.dart';

// class Dijkstra {
//   Map<String, List<String>> adjacencyList;

//   Dijkstra(this.adjacencyList);

//   List<String> findShortestPath(String start, String end) {
//     Map<String, double> distance = {};
//     Map<String, String> previous = {};
//     PriorityQueue<String> priorityQueue = PriorityQueue<String>(
//       compare: (a, b) => distance[a]!.compareTo(distance[b]!),
//     );

//     // Initialization
//     for (var vertex in adjacencyList.keys) {
//       distance[vertex] = double.infinity;
//       previous[vertex] = '';
//     }
//     distance[start] = 0;

//     // Add all vertices to the priority queue
//     priorityQueue.addAll(adjacencyList.keys);

//     while (priorityQueue.isNotEmpty) {
//       String currentVertex = priorityQueue.removeFirst();

//       if (currentVertex == end) {
//         List<String> path = [];
//         while (previous[currentVertex] != '') {
//           path.insert(0, currentVertex);
//           currentVertex = previous[currentVertex]!;
//         }
//         path.insert(0, start);
//         return path;
//       }

//       for (var neighbor in adjacencyList[currentVertex]!) {
//         double alt = distance[currentVertex]! + 1; // Assuming each edge has a weight of 1

//         if (alt < distance[neighbor]!) {
//           distance[neighbor] = alt;
//           previous[neighbor] = currentVertex;
//           priorityQueue.remove(neighbor);
//           priorityQueue.add(neighbor);
//         }
//       }
//     }

//     return [];
//   }
// }
