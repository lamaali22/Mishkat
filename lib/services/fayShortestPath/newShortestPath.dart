import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:mishkat/services/fayShortestPath/dijkstra.dart';
import 'package:mishkat/services/fayShortestPath/newIndoorGraph.dart';
import 'package:mishkat/utils/geojsonData.dart';

class ShortestPath {
  static RoomGraph roomGraph = RoomGraph();

  static Future<Set<String>> calculateShortestPath(
    LatLng userLocation,
    LatLng tappedLocation,
  ) async {
    print('roomGraph initially is ${roomGraph.nodes}');
    String startNodeId = roomGraph.findNearestNode(userLocation);
    String endNodeId = roomGraph.findNearestNode(tappedLocation);

    Set<String> shortestPath = await findShortestPath(startNodeId, endNodeId);

    print('shortestPath is $shortestPath');
    return shortestPath;
  }

  static Future<Set<String>> findShortestPath(
    String startNodeId,
    String endNodeId,
  ) async {
    print('start of findShortestPath');
    roomGraph = buildRoomGraph(geojsonDataX);

    Map<String, double> distances = dijkstra(roomGraph, startNodeId);

    Set<String> shortestPath = {};
    String currentRoomId = endNodeId;

    while (currentRoomId != startNodeId) {
      print('currentRoomId != startNodeId');
      roomGraph.edges.forEach((edge) {
        if (edge.connectedRooms.contains(currentRoomId)) {
          print('edge contains currentRoomId');
          double totalDistance = distances[currentRoomId]! - calculateEdgeWeight(edge, roomGraph.getNodeById(currentRoomId)!);
          print('inside loop');
          if (totalDistance == distances[edge.connectedRooms.first]) {
            shortestPath.add(edge.connectedRooms.first);
            currentRoomId = edge.connectedRooms.first;
          }
        }
      });
    }
    print('currentRoomId is startNodeId');

    shortestPath.add(startNodeId);
    print('startNodeId is $startNodeId');
    print('shortestPath after startNode $shortestPath');
    return shortestPath;
  }

  static double calculateEdgeWeight(RoomEdge edge, RoomNode startNode) {
    List<double> startCoordinates = startNode.coordinates;
    List<double> endCoordinates = edge.coordinates.last;
    double distance = calculateDistance(startCoordinates, endCoordinates);
    return distance;
  }

  static double calculateDistance(List<double> start, List<double> end) {
    double dx = end[0] - start[0];
    double dy = end[1] - start[1];
    return sqrt((dx * dx + dy * dy));
  }
}
