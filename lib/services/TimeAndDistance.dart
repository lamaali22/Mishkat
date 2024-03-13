import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeAndDistance {
  Future<void> showTimeAndDistance(
    BuildContext context,
    double d,
    double t,
  ) async {
    double distance = 0;
    String disUnit = "";
    double time = 0;
    String timeUnit = "";

    if (d > 100) {
      distance = d / 100;
      disUnit = "km";
    } else {
      distance = d;
      disUnit = "meters";
    }

    if (t > 60) {
      time = t / 60;
      timeUnit = "hours";
    } else {
      time = t;
      timeUnit = "minutes";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(0, -5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  color: Color(0xFF09186C),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "  ${time.toStringAsFixed(0)}  $timeUnit",
                                  style: TextStyle(
                                    color: Color(0xFF09186C),
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              "        ${distance.toStringAsFixed(0)}  $disUnit",
                              style: TextStyle(
                                color: Color(0xFF09186C),
                                fontSize: 19,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            "Start",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 23.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFF09186C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: Size(190, 63),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  double calculateWalkingTime(double distance) {
    double speed = 90;
    // Calculate time in minutes
    double timeInMinutes = distance / speed;
    print(" timeInMinutes $timeInMinutes");

    // Return the time in minutes
    return timeInMinutes;
  }
}
