import 'dart:math';
import 'package:collection/collection.dart';
import 'package:mishkat/utils/geojsonData.dart';
  
  Map<String, dynamic> geojsonData = geojsonDataX;

class IndoorGraph {
  //late Map<String, dynamic> geojsonData;
  Map<String, List<String>> adjacencyList = {};
  Map<String, List<double>> nodeCenters = {}; // To hold the center coordinates of nodes

  IndoorGraph() {
    _constructGraph();
  }

  void _constructGraph() {
    for (var feature in geojsonData['features']) {
      var roomId = feature['properties']['roomId'];
      var geometry = feature['geometry'];
      var connections = feature['properties']['connections'];

      if (connections != null) {
        print(connections);
        adjacencyList[roomId] = connections;
      }

    if (geometry['type'] == 'Polygon' && geometry['coordinates'][0].length > 1) {
          print('room $roomId is Polygon');
          
          nodeCenters[roomId] = _calculateCenter(geometry['coordinates'][0]);
        } else if (geometry['type'] == 'Point') {
          print('room $roomId is point');

          nodeCenters[roomId] = geometry['coordinates'];
        } else if (geometry['type'] == 'LineString' && geometry['coordinates'].length >= 2) {
          print('room $roomId is linestring');

          nodeCenters[roomId] = _calculateLineStringCenter(geometry['coordinates']);
        }
    }
    print('_constructGraph ${adjacencyList.entries} ${nodeCenters.entries}');
  }

    // Implement Dijkstra's algorithm or any other graph search algorithm here

  Map<String, Map<String, dynamic>> dijkstra(String startNodeId) {
    Map<String, double> distances = {}; // Holds the shortest distance from start to each node
    Map<String, String> previous = {}; // Holds the previous node in the shortest path
    Set<String> visited = Set<String>(); // Keeps track of visited nodes
    PriorityQueue<MapEntry<String, double>> queue = PriorityQueue<MapEntry<String, double>>(
      (a, b) => a.value.compareTo(b.value)
    );

    // Initialize distances and queue
    for (String nodeId in adjacencyList.keys) {
      distances[nodeId] = double.infinity;
      queue.add(MapEntry(nodeId, double.infinity));
    }
    distances[startNodeId] = 0.0;
    queue.add(MapEntry(startNodeId, 0.0));

    while (queue.isNotEmpty) {
      String current = queue.removeFirst().key;
      if (visited.contains(current)) continue; // Skip if already visited
      visited.add(current);

      for (String neighbor in getConnections(current)) {
      if (!distances.containsKey(neighbor)) {
          print("Warning: Neighbor '$neighbor' not found in distances map.");
          continue;
        } // Skip if neighbor is already visited

        double altDistance = distances[current]! + _calculateDistance(getNodeCenter(current), getNodeCenter(neighbor));
        print('altDistance is $altDistance');
        if (altDistance < distances[neighbor]!) {
          distances[neighbor] = altDistance;
          previous[neighbor] = current;
          queue.add(MapEntry(neighbor, altDistance));
        }
      }
    }

    // Print the result of the Dijkstra's algorithm
    print("Dijkstra's algorithm result from node $startNodeId:");
    print("Distances: $distances");
    print("Previous nodes: $previous");

    return {'distances': distances, 'previous': previous};
  }


    // Helper function to calculate the center of a polygon
    List<double> _calculateCenter(List<List<double>> coordinates) {
      double avgX = 0.0;
      double avgY = 0.0;
      for (var coord in coordinates) {
        avgX += coord[0];
        avgY += coord[1];
      }
      avgX /= coordinates.length;
      avgY /= coordinates.length;
      return [avgX, avgY];
    }
    
    List<String> getConnections(String roomId) {
      return adjacencyList[roomId] ?? [];
    }

    List<double> getNodeCenter(String roomId) {
      print('nodeCenters for room $roomId ${nodeCenters[roomId]}');
      return nodeCenters[roomId] ?? [];
    }

    // Helper function to calculate the Euclidean distance between two points
    double _calculateDistance(List<double> start, List<double> end) {
      double dx = end[0] - start[0];
      double dy = end[1] - start[1];
      print('_calculateDistance ${sqrt((dx * dx + dy * dy))}'); 
      return sqrt((dx * dx + dy * dy));
    }

    List<double> _calculateLineStringCenter(List<List<double>> coordinates) {
      if (coordinates.length <= 2) return _calculateSimpleLineStringCenter(coordinates);

    // Calculate the midpoint of the entire LineString to use as a reference
      List<double> entireLineMidpoint = _calculateSimpleLineStringCenter(coordinates);

      // Divide the LineString into three segments
      int segmentLength = (coordinates.length / 3).round();
      List<List<double>> segment1 = coordinates.take(segmentLength).toList();
      List<List<double>> segment2 = coordinates.skip(segmentLength).take(segmentLength).toList();
      List<List<double>> segment3 = coordinates.skip(2 * segmentLength).toList();

      // Calculate the center for each segment
      List<double> centerSegment1 = _calculateSimpleLineStringCenter(segment1);
      List<double> centerSegment2 = _calculateSimpleLineStringCenter(segment2);
      List<double> centerSegment3 = _calculateSimpleLineStringCenter(segment3);

      // Find the nearest center to the entire line midpoint
      List<double> nearestCenter = centerSegment1;
      double nearestDistance = _calculateDistance(entireLineMidpoint, centerSegment1);

      double distanceSegment2 = _calculateDistance(entireLineMidpoint, centerSegment2);
      if (distanceSegment2 < nearestDistance) {
        nearestCenter = centerSegment2;
        nearestDistance = distanceSegment2;
      }

      double distanceSegment3 = _calculateDistance(entireLineMidpoint, centerSegment3);
      if (distanceSegment3 < nearestDistance) {
        nearestCenter = centerSegment3;
        nearestDistance = distanceSegment3;
      }

      return nearestCenter;
    }

    List<double> _calculateSimpleLineStringCenter(List<List<double>> coordinates) {
    double avgX = 0.0;
    double avgY = 0.0;
    for (var coord in coordinates) {
      avgX += coord[0];
      avgY += coord[1];
    }
    avgX /= coordinates.length;
    avgY /= coordinates.length;
    return [avgX, avgY];
  }

}

