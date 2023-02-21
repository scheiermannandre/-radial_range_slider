import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:radial_range_slider/quadrant.dart';

abstract class DragObjectState {
  final double _radius;
  late bool isHovered = false;
  late Offset dragObjectPosition;
  late Offset _pointerPosition;
  late double _center;
  late double currentDragObjectAngle = 0;
  late double _currentPointerAngle = 0;
  late Quadrant _dragObjectQuadrant;
  late Quadrant _pointerQuadrant;
  late double _revolution = 0;
  late double _minAngle;
  @protected late double maxAngle;

  late Quadrant _prevousPointerQuadrant;

  late double dragObjectArchAngle;
  late double dragObjectDistanceAngle;

  late double value = 0;
  DragObjectState(double initialValue, this._radius, double boxSize,
      double dragObjectSize, double minEnd, double maxEnd) {
    assert(initialValue >= 0 && initialValue <= 1);
    assert(minEnd >= 0 && minEnd <= 1);
    assert(maxEnd >= 0 && maxEnd <= 1);
    assert(minEnd < maxEnd && maxEnd > minEnd);

    _center = (boxSize - dragObjectSize) / 2;
    dragObjectDistanceAngle = degrees(dragObjectSize / _radius);
    dragObjectArchAngle = dragObjectDistanceAngle / 2;
    _minAngle = 360 * minEnd + dragObjectArchAngle;
    maxAngle = 360 * maxEnd - dragObjectArchAngle;
    double angle;
    if (initialValue == 0) {
      angle = dragObjectArchAngle;
    } else {
      angle = maxAngle * initialValue;
    }

    setDragObjectPosition(angle);
    _pointerPosition = dragObjectPosition;
    _pointerQuadrant = _dragObjectQuadrant;
  }

  void setQuadrantFromAngle(double angle) {
    if (angle >= 0 && angle < 90) {
      _dragObjectQuadrant = Quadrant.upperRight;
    } else if (angle >= 90 && angle < 180) {
      _dragObjectQuadrant = Quadrant.upperLeft;
    } else if (angle >= 180 && angle < 270) {
      _dragObjectQuadrant = Quadrant.lowerLeft;
    } else {
      _dragObjectQuadrant = Quadrant.lowerRight;
    }
  }

  void setDragObjectPosition(double angleDeg) {
    double x = _radius * cos(radians(-angleDeg)) + _center;
    double y = _radius * sin(radians(-angleDeg)) + _center;
    currentDragObjectAngle = angleDeg;
    setQuadrantFromAngle(angleDeg);
    dragObjectPosition = Offset(x, y);
    setValue();
  }

  void setValue();

  void mouseEnter(PointerEnterEvent event) {
    isHovered = true;
  }

  void mouseExit(PointerExitEvent event) {
    isHovered = false;
  }

  double dragUpdate(DragUpdateDetails details) {
    isHovered = true;
    _pointerPosition = Offset(_pointerPosition.dx + details.delta.dx,
        _pointerPosition.dy + details.delta.dy);
    return calculateDragObjectPosition();
  }

  void dragEnd(DraggableDetails details) {
    _pointerPosition = dragObjectPosition;
    _prevousPointerQuadrant = _dragObjectQuadrant;
    _pointerQuadrant = _dragObjectQuadrant;
    isHovered = false;
    _revolution = 0;
  }

  double calculateDragObjectPosition() {
    double angle = calculatePointerAngle();
    if (_currentPointerAngle > maxAngle) {
      angle = maxAngle;
    } else if (_currentPointerAngle < _minAngle) {
      angle = _minAngle;
    }
    return angle;
  }

  double calculatePointerAngle() {
    // 1. Calculate the pointers position relative to the center
    Offset relativePointerPosition =
        Offset(_pointerPosition.dx - _center, _pointerPosition.dy - _center);

    // 2. Calculate the hypotenuse in order to get distance between pointer and center
    double hypotenuse = calculateHypotenuse(relativePointerPosition);

    // 3. Calculate the angle the pointer has in relation to the x-axis
    double angleRad = asin(relativePointerPosition.dy / hypotenuse);
    double angleDeg = degrees(angleRad);

    // 4. Check in which quadrant the pointer lies
    setPointerQuadrant(relativePointerPosition.dx, relativePointerPosition.dy);

    // 5. The quadrant angle is always 0-90 degree, a conversion to absolute degrees has to be made
    angleDeg = quadrantAngleToAbsolute(angleDeg);

    calculateRevolution();
    _currentPointerAngle = 360 * _revolution + angleDeg;
    return angleDeg;
  }

  /// Calculation of the radius from center to pointer
  /// (x - mx)^2 + (y - my)^2 = r^2
  double calculateHypotenuse(Offset pointerPosition) {
    double xSquare = pow(pointerPosition.dx, 2).toDouble();
    double ySquare = pow(pointerPosition.dy, 2).toDouble();

    double rSquare = xSquare + ySquare;
    double radius = sqrt(rSquare);

    return radius;
  }

  void setPointerQuadrant(num dx, num dy) {
    _prevousPointerQuadrant = _pointerQuadrant;
    if (dx >= 0 && dy <= 0) {
      _pointerQuadrant = Quadrant.upperRight;
    } else if (dx <= 0 && dy <= 0) {
      _pointerQuadrant = Quadrant.upperLeft;
    } else if (dx <= 0 && dy >= 0) {
      _pointerQuadrant = Quadrant.lowerLeft;
    } else if (dx >= 0 && dy >= 0) {
      _pointerQuadrant = Quadrant.lowerRight;
    } else {
      throw Exception("Error in calculating the Quadrants");
    }
  }

  void calculateRevolution() {
    if (_prevousPointerQuadrant == Quadrant.lowerRight &&
        _pointerQuadrant == Quadrant.upperRight) {
      _revolution++;
    } else if (_prevousPointerQuadrant == Quadrant.upperRight &&
        _pointerQuadrant == Quadrant.lowerRight) {
      _revolution--;
    }
  }

  double quadrantAngleToAbsolute(double angle) {
    if (_pointerQuadrant == Quadrant.upperRight) {
      angle *= -1;
    } else if (_pointerQuadrant == Quadrant.upperLeft) {
      angle = 180 + angle;
    } else if (_pointerQuadrant == Quadrant.lowerLeft) {
      angle = 180 + angle;
    } else if (_pointerQuadrant == Quadrant.lowerRight) {
      angle = 360 - angle;
    }
    return angle;
  }

  double degrees(double rad) {
    return rad * 180 / pi;
  }

  double radians(double degrees) {
    return degrees * pi / 180;
  }
}
