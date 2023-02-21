
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:radial_range_slider/drag_object_state.dart';

class DragObject extends StatelessWidget {
  final DragObjectState state;
  final Color color;
  final double size;
  final Function(PointerEnterEvent event) mouseEnter;
  final Function(PointerExitEvent event) mouseExit;
  final Function(DragUpdateDetails details) dragUpdate;
  final Function(DraggableDetails details) dragEnd;
  const DragObject(
      {super.key,
      required this.state,
      required this.color,
      required this.size,
      required this.mouseEnter,
      required this.mouseExit,
      required this.dragUpdate,
      required this.dragEnd});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: state.dragObjectPosition.dx,
      top: state.dragObjectPosition.dy,
      child: MouseRegion(
        onEnter: (event) => mouseEnter(event),
        onExit: (event) => mouseExit(event),
        cursor: SystemMouseCursors.click,
        child: Draggable(
          onDragUpdate: (details) => dragUpdate(details),
          onDragEnd: (details) => dragEnd(details),
          feedback: const SizedBox.shrink(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 75),
            height: size,
            width: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(.3),
                  spreadRadius: state.isHovered ? 0.75 * size : 0,
                  blurRadius: 0,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}