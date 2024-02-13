import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Polygon {
  final List<LatLng> points;
  final bool isFilled;
  final Color color;
  final double borderStrokeWidth;
  final Color borderColor;
  final bool isDotted;
  final Map<String, dynamic>? properties; // Added properties for highlighting

  Polygon({
    required this.points,
    required this.isFilled,
    required this.color,
    required this.borderStrokeWidth,
    required this.borderColor,
    required this.isDotted,
    this.properties, // Added properties for highlighting
  });
}

class Marker {
  final LatLng point;
  final Widget Function(BuildContext) builder;
  final Map<String, dynamic>? properties; // Added properties for highlighting

  Marker({
    required this.point,
    required this.builder,
    this.properties, // Added properties for highlighting
  });
}
