import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:radial_range_slider/drag_object.dart';
import 'package:radial_range_slider/drag_object_state.dart';
import 'package:radial_range_slider/max_drag_object_state.dart';
import 'package:radial_range_slider/min_drag_object_state.dart';

class RadialRangeSlider extends StatefulWidget {
  const RadialRangeSlider({super.key});

  @override
  State<StatefulWidget> createState() => _RadialRangeSliderState();
}

class _RadialRangeSliderState extends State<RadialRangeSlider> {
  double radius = 125;
  double boxSize = 300;
  double dragObjectSize = 25;

  late MinDragObjectState minDragObject;
  late MaxDragObjectState maxDragObject;

  @override
  void initState() {
    super.initState();
    maxDragObject =
        MaxDragObjectState(.75, radius, boxSize, dragObjectSize, 0, 1);
    minDragObject =
        MinDragObjectState(0, radius, boxSize, dragObjectSize, 0, 1);
  }

  void mouseEnter(PointerEnterEvent event, DragObjectState? state) {
    setState(() {
      state?.mouseEnter(event);
    });
  }

  void mouseExit(PointerExitEvent event, DragObjectState? state) {
    setState(() {
      state?.mouseExit(event);
    });
  }

  late double value = 0;
  void dragUpdateMaxDragObject(DragUpdateDetails details,
      MaxDragObjectState maxDragObject, MinDragObjectState minDragObject) {
    setState(() {
      double? upperAngle = minDragObject.dragUpdate(details);
      double? lowerAngle = maxDragObject.currentDragObjectAngle -
          maxDragObject.dragObjectDistanceAngle;
      if (upperAngle > lowerAngle) {
        upperAngle = lowerAngle;
      }
      minDragObject.setDragObjectPosition(upperAngle);
      // print(
      //     "upperDragObject angle: ${upperDragObject._currentDragObjectAngle}");

      dragUpdateFinish(maxDragObject, minDragObject);
    });
  }

  void dragUpdateMinDragObject(DragUpdateDetails details,
      MinDragObjectState minDragObject, MaxDragObjectState maxDragObject) {
    setState(() {
      double upperAngle = minDragObject.currentDragObjectAngle +
          minDragObject.dragObjectDistanceAngle;
      double lowerAngle = maxDragObject.dragUpdate(details);

      if (lowerAngle < upperAngle) {
        lowerAngle = upperAngle;
      }
      maxDragObject.setDragObjectPosition(lowerAngle);
      dragUpdateFinish(maxDragObject, minDragObject);
    });
  }

  String startTime = "00:00";
  String endTime = "00:00";

  void dragUpdateFinish(
      DragObjectState lowerDragObject, DragObjectState upperDragObject) {
   
    int minOfDay = 24 * 60;
    Duration start =
        Duration(minutes: (minOfDay * lowerDragObject.value).round());
    Duration end =
        Duration(minutes: (minOfDay * upperDragObject.value).round());

    startTime = durationToHHMM(start);
    endTime = durationToHHMM(end);

    print("start value : $start end value: $end");
  }

  String durationToHHMM(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    if (duration.inDays != 0) {
      return " 24:00";
    }
    final String hours = twoDigits(duration.inHours.remainder(24));
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    return " $hours:$minutes";
  }

  void dragEnd(DraggableDetails details, DragObjectState? state) {
    setState(() {
      state?.dragEnd(details);
    });
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 200.0),
          child: Column(
            children: [
              Container(
                color: Colors.transparent,
                height: boxSize,
                width: boxSize,
                child: Transform.rotate(
                  angle: -2 * pi,
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Container(
                          alignment: Alignment.center,
                          height: radius + boxSize / 2,
                          width: radius + boxSize / 2,
                          decoration: const BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                startTime,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const Text(
                                "-",
                                style: TextStyle(fontSize: 24),
                              ),
                              Text(
                                endTime,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DragObject(
                        state: minDragObject,
                        color: Colors.green,
                        size: dragObjectSize,
                        mouseEnter: (event) => mouseEnter(event, minDragObject),
                        mouseExit: (event) => mouseExit(event, minDragObject),
                        dragUpdate: (details) => dragUpdateMaxDragObject(
                            details, maxDragObject, minDragObject),
                        dragEnd: (details) => dragEnd(details, minDragObject),
                      ),
                      DragObject(
                        state: maxDragObject,
                        color: Colors.orange,
                        size: dragObjectSize,
                        mouseEnter: (event) => mouseEnter(event, maxDragObject),
                        mouseExit: (event) => mouseExit(event, maxDragObject),
                        dragUpdate: (details) => dragUpdateMinDragObject(
                            details, minDragObject, maxDragObject),
                        dragEnd: (details) => dragEnd(details, maxDragObject),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
