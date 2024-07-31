import 'package:flutter/material.dart';

import '../../mixins/overlay_mixin.dart';
import '../../models/appointment_item.dart';
import '../../scheduler.dart';
import '../../services/appointment_drag_service.dart';
import '../../services/ui_service.dart';

class AppointmentResizer extends StatefulWidget {
  final Widget child;
  final AppointmentItem appointmentItem;
  final AppointmentWidget appointmentWidget;
  final FlowOrientation orientation;
  final bool hovered;
  const AppointmentResizer({
    Key? key,
    required this.appointmentWidget,
    required this.child,
    required this.orientation,
    required this.appointmentItem,
    required this.hovered,
  }) : super(key: key);

  @override
  State<AppointmentResizer> createState() => _AppointmentResizerState();
}

class _AppointmentResizerState extends State<AppointmentResizer> with OverlayMixin {
  ValueNotifier<Offset> sizeChangeNotifier = ValueNotifier<Offset>(Offset.zero);
  MouseCursor sizerCursor = SystemMouseCursors.none;

  bool _sizing = false;
  bool get sizing => _sizing && mounted;

  set sizing(bool value) {
    if (value != _sizing) {
      _sizing = value;
      _setSizingOverlay();
    }
  }

  _setSizingOverlay(){
    if (sizing){
      final renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;
      final offset = renderBox.localToGlobal(Offset.zero);
      final rect = Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
      insertOverlay(SizingFeedback(clientRect: rect, cursor: sizerCursor));
    } else {
      removeOverlay();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      widget.child,
      SizingHandle(
          appointmentItem: widget.appointmentItem,
          onSizing: (isSizing, cursor) {sizerCursor = cursor; sizing = isSizing;},
          widget: widget,
          sizeChangeNotifier: sizeChangeNotifier,
          orientation: widget.orientation,
          index: 0,),
      SizingHandle(
          appointmentItem: widget.appointmentItem,
          onSizing: (isSizing, cursor) {sizerCursor = cursor; sizing = isSizing; },
          widget: widget,
          sizeChangeNotifier: sizeChangeNotifier,
          orientation: widget.orientation,
          index: 1,),
    ]);
  }
}


class SizingFeedback extends StatelessWidget {
  final Rect clientRect;
  final MouseCursor cursor;
  const SizingFeedback({super.key, required this.clientRect, required this.cursor});

  Rect resize(Offset change){
    double top = clientRect.top;
    double left = clientRect.left;
    double height = clientRect.height;
    double width = clientRect.width;
    switch(AppointmentDragService.instance.dragSizeDirection) {
      case SizingDirection.left:
        left = left + change.dx;
        width = width - change.dx;
        break;
      case SizingDirection.right:
        width = width + change.dx;
        break;
      case SizingDirection.up:
        top = top + change.dy;
        height = height - change.dy;
        break;
      case SizingDirection.down:
        height = height + change.dy;
        break;
      case SizingDirection.none:
        break;
    }

    if (height <= 0 || width <= 0){
      return clientRect;
    }

    return Rect.fromLTWH(left, top, width, height);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppointmentDragService.instance.appointmentDragUpdate,
      builder: (BuildContext context, AppointmentDragUpdateDetails? dragDetails, Widget? child) {
        var rect = clientRect;
        if (dragDetails != null) {
          Offset delta = dragDetails.change;
          rect = resize(delta);
        }
        var sizerFeedback = Positioned(
          height: rect.height,
          width: rect.width,
          left: rect.left,
          top: rect.top,
          child: MouseRegion(
            cursor: cursor,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                border: Border.all(color: Colors.orange),
                borderRadius: const BorderRadius.all(Radius.circular(4)),
              ),
            ),
          ),
        );
        
        return sizerFeedback;
      },
    );
  }
}

class SizingHandle extends StatefulWidget {
  final Function(bool isSizing, MouseCursor cursor) onSizing;
  final AppointmentItem appointmentItem;
  final FlowOrientation orientation;
  final int index;
  final AppointmentResizer widget;
  final ValueNotifier<Offset> sizeChangeNotifier;
  const SizingHandle({
    super.key,
    required this.onSizing,
    required this.widget,
    required this.appointmentItem,
    required this.sizeChangeNotifier,
    required this.orientation,
    required this.index,
  });

  @override
  SizingHandleState createState() => SizingHandleState();
}

class SizingHandleState extends State<SizingHandle> {
  double initX = 0;
  double initY = 0;
  double handleDiameter = 0;

  late double height;
  late double width;
  late double top;
  late double left;
  late SizingDirection sizingDirection;
  late MouseCursor cursor;
  late AlignmentDirectional alignment;

  ValueNotifier<Offset> sizeChangeNotifier = ValueNotifier<Offset>(Offset.zero);

  _handleDrag(Offset initialPos) {
    initX = initialPos.dx;
    initY = initialPos.dy;
    AppointmentDragService.instance.prepareDragSize(sizingDirection);
  }

  _handleUpdate(Offset position) {
    var dx = position.dx - initX;
    var dy = position.dy - initY;
    widget.sizeChangeNotifier.value = Offset(dx, dy);
    sizeChangeNotifier.value = Offset(dx, dy);
  }

  @override
  initState() {
    initSizing();
    super.initState();
  }

  initSizing() {
    double size = 8;
    Rect rect = widget.appointmentItem.geometry.rect;
    width = rect.width;
    height = rect.height;
    if (widget.orientation == FlowOrientation.vertical) {
      height = size;
      left = 0;
      top = 0;
      sizingDirection = SizingDirection.up;
      if (widget.index == 1) {
        top = rect.height - height;
        sizingDirection = SizingDirection.down;
      }
      cursor = SystemMouseCursors.resizeUpDown;
    } else {
      width = size;
      top = 0;
      left = 0;
      sizingDirection = SizingDirection.left;
      if (widget.index == 1) {
        left = rect.width - width;
        sizingDirection = SizingDirection.right;
      }
      cursor = SystemMouseCursors.resizeLeftRight;
    }
  }

  @override
  Widget build(BuildContext context) {
    initSizing();

    return ValueListenableBuilder(
        valueListenable: sizeChangeNotifier,
        builder: (BuildContext context, Offset change, Widget? child) {

      return Positioned(
            top: top + change.dy,
            left: left,
            child: Listener(
              onPointerDown: (event) {
                _handleDrag(event.position);
              },
              onPointerMove: (event) {
                widget.onSizing(event.down, cursor);
                if (event.down) {
                  _handleUpdate(event.position);
                }
              },
              onPointerUp: (event) {
                widget.onSizing(false, cursor);
                sizeChangeNotifier.value = Offset.zero;
                UIService.instance.topMostNotifier.value = null;
              },
              child: MouseRegion(
                //hitTestBehavior: HitTestBehavior.opaque,
                cursor: cursor,
                child: Container(
                  width: width,
                  height: height,
                  color: Colors.transparent,
                ),
              ),
            ),
          );
        },);
  }
}
