import 'dart:math';
import 'package:collection/collection.dart';
import 'package:mishkat/services/fayShortestPath/newIndoorGraph.dart';

Map<String, double> dijkstra(RoomGraph roomGraph, String startId) {
  Map<String, double> distances = {};
  PriorityQueue<String> priorityQueue = PriorityQueue<String>((a, b) =>
      (distances[a] ?? double.infinity)
          .compareTo(distances[b] ?? double.infinity));

  roomGraph.nodes.keys.forEach((id) {
    distances[id] = double.infinity;
    priorityQueue.add(id);
  });

  distances[startId] = 0;

  while (priorityQueue.isNotEmpty) {
    String currentId = priorityQueue.removeFirst();

    roomGraph.edges.forEach((edge) {
      if (edge.connectedRooms.contains(currentId)) {
        double newDistance = distances[currentId]! +
            calculateEdgeWeight(edge, roomGraph.getNodeById(currentId)!);
        if (newDistance < distances[edge.connectedRooms.first]!) {
          distances[edge.connectedRooms.first] = newDistance;
          priorityQueue.remove(edge.connectedRooms.first);
          priorityQueue.add(edge.connectedRooms.first);
        }
      }
    });
  }
  print('distances are $distances');
  return distances;
}

double calculateEdgeWeight(RoomEdge edge, RoomNode startNode) {
  List<double> startCoordinates = startNode.coordinates;
  List<double> endCoordinates = edge.coordinates.last;
  double distance = calculateDistance(startCoordinates, endCoordinates);
  
  print('weight of node ${startNode} is $distance');
  return distance;
}

double calculateDistance(List<double> start, List<double> end) {
  double dx = end[0] - start[0];
  double dy = end[1] - start[1];
  return sqrt((dx * dx + dy * dy) );
}
