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
    roomGraph = buildRoomGraph(geojsonDataX);
    print('roomGraph.nodes after building is ${roomGraph.nodes}');
    print('roomGraph.edges after building is ${roomGraph.edges.toList()}');


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
    print('distance from dijkstra is $distances');

    Set<String> shortestPath = {};
    String currentRoomId = endNodeId;
    int X =0;

    while ( X != 20) {
      X++;
      // print('currentRoomId != startNodeId');

      // print("roomGraph.edges is empty? ${roomGraph.edges.isEmpty}");
      roomGraph.edges.forEach((edge) {
        X++;
        if (edge.connectedRooms.contains(currentRoomId)) {
          print('edge contains currentRoomId');

          double totalDistance = distances[currentRoomId]! - calculateEdgeWeight(edge, roomGraph.getNodeById(currentRoomId)!);
          print('totalDistance is $totalDistance');

          double tolerance = 1e-10; // Adjust the tolerance value based on your requirements
          if ((totalDistance - distances[edge.connectedRooms.first]!).abs() < tolerance) {
            print('totalDistance == distances[edge.connectedRooms.first] is true');
            shortestPath.add(edge.connectedRooms.first);
            currentRoomId = edge.connectedRooms.first;
          }
        }
      });
    }
    print('currentRoomId is startNodeId');

    shortestPath.add(startNodeId);
    print('startNodeId is empty ${startNodeId.isEmpty}');
    print('shortestPath after startNode $shortestPath');
    return shortestPath;
  }

  static double calculateEdgeWeight(RoomEdge edge, RoomNode startNode) {
    List<double> startCoordinates = startNode.coordinates;
    List<double> endCoordinates = edge.coordinates.last;
    double distance = calculateDistance(startCoordinates, endCoordinates);

    print('result of calculateEdgeWeight is $distance ');
    return distance;
  }

  static double calculateDistance(List<double> start, List<double> end) {
    double dx = end[0] - start[0];
    double dy = end[1] - start[1];
    return sqrt((dx * dx + dy * dy));
}

}
