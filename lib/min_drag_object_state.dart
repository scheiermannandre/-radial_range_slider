import 'package:radial_range_slider/drag_object_state.dart';

class MinDragObjectState extends DragObjectState {
  MinDragObjectState(super.initialValue, super.radius, super.boxSize,
      super.dragObjectSize, super.minEnd, super.maxEnd);

  @override
  void setValue() {
    double tmp = dragObjectDistanceAngle + dragObjectArchAngle;
    tmp *= -1;
    double range = maxAngle + tmp;
    double angleOnRage = currentDragObjectAngle - dragObjectArchAngle;
    value = angleOnRage / range;
    value = (value - 1) * -1;
  }
}