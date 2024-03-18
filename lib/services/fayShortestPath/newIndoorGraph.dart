import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';
// import 'package:mishkat/utils/geojsonData.dart';
import 'dart:math' as math;

class RoomNode {
  String id;
  List<double> coordinates;
  List<String> connectedRooms;
  List<String> connectedPaths;

  RoomNode({
    required this.id,
    required this.coordinates,
    required this.connectedRooms,
    required this.connectedPaths,
  });
}


class RoomEdge {
  int pathId;
  List<String> connectedRooms;
  List<int> connectedPaths;
  List<List<double>> coordinates; // Coordinates of the path's line

  RoomEdge({
    required this.pathId,
    required this.connectedRooms,
    required this.connectedPaths,
    required this.coordinates,
  });
}


class RoomGraph {
  Map<String, RoomNode> nodes = {};
  Set<RoomEdge> edges = {};

  void addNode(RoomNode node) {
    nodes[node.id] = node;
  }

  void addEdge(RoomEdge edge) {
    edges.add(edge);
  }

  String findNearestNode(LatLng point) {
    double minDistance = double.infinity;
    String nearestNodeId = '';
    print('inside findNearestNode recieved point is $point');

    nodes.forEach((id, node) {
      double distance = calculateDistance(point, LatLng(node.coordinates[1], node.coordinates[0]));
      if (distance < minDistance) {
        minDistance = distance;
        nearestNodeId = id;
      }
    });
    print('nearestNode to current location is $nearestNodeId');
    return nearestNodeId;
  }
  
  double calculateDistance(LatLng point1, LatLng point2) {
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
  
  RoomNode? getNodeById(String id) {
    return nodes[id];
  }
}

RoomGraph buildRoomGraph(Map<String, dynamic> geoJson) {
  RoomGraph roomGraph = RoomGraph();

  print('before parsing');
  if (geoJson != null) {
    print('geojson is not null');
    List<dynamic>? features = geoJson['features'];

    if (features != null) {
      print('features is not null');
      features.forEach((feature) {
        if (feature['properties'].containsKey('roomId')) {
          print('there is roomId');
          String roomId = feature['properties']['roomId'];
          List<dynamic> polygonCoordinates = feature['geometry']['coordinates'][0];

          List<String> connectedRooms = [];
          List<int> connectedPaths = [];

          if (feature['properties']['connectedRooms'] != null) {
            connectedRooms = List<String>.from(feature['properties']['connectedRooms']);
            print('connectedRooms are ${connectedRooms.length}');
          } else {
            print('Connected rooms is null for room $roomId');
          }

          if (feature['properties']['connectedPaths'] != null) {
            connectedPaths = List<int>.from(feature['properties']['connectedPaths']);
            print('connectedPaths are ${connectedPaths.length}');
          } else {
            print('Connected paths are null for roomId: $roomId');
          }

          RoomNode roomNode = RoomNode(
            id: roomId,
            coordinates: calculateRoomCenter(polygonCoordinates),
            connectedRooms: connectedRooms,
            connectedPaths: [],
          );

          print('room graph before node ${roomGraph.nodes}');

          roomGraph.addNode(roomNode);
          print('room graph after node ${roomGraph.nodes}');
          print('roomNode is ${roomNode.id}');

          if (connectedRooms.isNotEmpty) {
            print('theres connectedRooms');
            connectedRooms.forEach((connectedRoomId) {
              RoomEdge edge = RoomEdge(
                pathId: 0, // Assuming it's a room node, so pathId is 0
                connectedRooms: [roomId, connectedRoomId], // Edge connects current room with connected room
                connectedPaths: [],
                coordinates: [], // No coordinates for room nodes
              );
              roomGraph.addEdge(edge);
            });
          }
        } else if (feature['properties'].containsKey('pathID')) {
          int pathId = feature['properties']['pathID'];
          List<int>? connectedPaths = feature['properties']['connectedPaths'] != null
              ? List<int>.from(feature['properties']['connectedPaths'])
              : [];

          List<dynamic>? coordinates = feature['geometry']['coordinates'];

          // Extract connected rooms from other features
          List<String> connectedRooms = [];
          features.forEach((otherFeature) {
            if (otherFeature['properties'].containsKey('connectedRooms')) {
              List<dynamic>? otherConnectedRooms = otherFeature['properties']['connectedRooms'];
              if (otherConnectedRooms != null && otherConnectedRooms.contains(pathId.toString())) {
                connectedRooms.add(otherFeature['properties']['roomId']);
              }
            }
          });

          RoomEdge edge = RoomEdge(
            pathId: pathId,
            connectedRooms: connectedRooms,
            connectedPaths: connectedPaths,
            coordinates: coordinates != null ? List<List<double>>.from(coordinates) : [],
          );

          roomGraph.addEdge(edge);

          // Add edges between the path and its connected paths
          if (connectedPaths.isNotEmpty) {
            connectedPaths.forEach((connectedPathId) {
              RoomEdge pathEdge = RoomEdge(
                pathId: connectedPathId,
                connectedRooms: [],
                connectedPaths: [],
                coordinates: [], // Coordinates will be filled if needed
              );
              roomGraph.addEdge(pathEdge);
            });
          }
        }
      });
    }
  }
  print('roomGraph nodes are ${roomGraph.nodes}');
  print('roomGraph edges are empty? ${roomGraph.edges.isEmpty}');
  return roomGraph;
}



List<double> calculateRoomCenter(List<dynamic> coordinates) {
  double sumX = 0.0;
  double sumY = 0.0;

  coordinates.forEach((coord) {
    sumX += coord[0];
    sumY += coord[1];
  });

  return [sumX / coordinates.length, sumY / coordinates.length];
}


