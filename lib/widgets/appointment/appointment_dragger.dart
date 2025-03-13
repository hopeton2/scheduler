import 'package:flutter/material.dart';
import 'package:scheduler/services/services.dart';

import '../../models/appointment_item.dart';
import '../../scheduler.dart';
import '../../services/appointment_drag_service.dart';
import '../../services/appointment_render_service.dart';
import '../../services/scheduler_service.dart';
import '../long_press_draggable_ex.dart';

class AppointmentDragger extends StatefulWidget {
  final AppointmentItem appointmentItem;
  final AppointmentRenderService appointmentRenderService;
  final FlowOrientation orientation;
  final Widget child;
  final AppointmentViewBuilder viewBuilder;
  const AppointmentDragger({
    super.key,
    required this.child,
    required this.viewBuilder,
    required this.orientation,
    required this.appointmentItem,
    required this.appointmentRenderService,
  });

  @override
  _AppointmentDraggerState createState() => _AppointmentDraggerState();
}

class _AppointmentDraggerState extends State<AppointmentDragger> {
  Scheduler scheduler = SchedulerService.instance.scheduler;
  Offset startingPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    Offset dragDelta = const Offset(0, 0);

    return Listener(
      onPointerDown: (event) {
        startingPosition = event.position;
      },
      child: LongPressDraggableEx<Appointment>(
        allowDragGesture: () => false,
        delay: Duration.zero, // scheduler.appointmentSettings.dragDelay,
        onDragStarted: () {
          AppointmentDragService()
              .beginDrag(widget.appointmentItem.appointment);
        },
        onDragUpdate: (DragUpdateDetails updateDetails) {
          dragDelta = Offset(
              updateDetails.globalPosition.dx - startingPosition.dx,
              updateDetails.globalPosition.dy - startingPosition.dy);
          AppointmentDragService().updateDrag(
              widget.appointmentItem.appointment, updateDetails, dragDelta);
        },
        onDragEnd: (DraggableDetails dragDetails) {
          if (appointmentDragService.isDragging) {
            var dragMode = appointmentDragService.dragMode;
            var appointment = widget.appointmentItem.appointment;
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            dragDelta = renderBox.globalToLocal(dragDetails.offset);
            appointmentDragService.endDrag(appointment, dragDetails);
            if (dragDelta.dx.abs() >= 1 || dragDelta.dy.abs() >= 1) {
              if (dragMode == DragMode.drag) {
                var renderService = widget.appointmentRenderService;
                var isAllDay = appointment.isAllDay;
                var allDayRect = viewService.allDayRect;
                if (allDayRect != null) {
                  if (!isAllDay &&
                      (dragDelta.dy + widget.appointmentItem.top) < 0) {
                    isAllDay = true;
                    dragDelta = Offset(dragDelta.dx, 0);
                    widget.appointmentItem.top = 1;
                    renderService = viewService.allDayRenderService!;
                  } else if (isAllDay &&
                      (dragDelta.dy + widget.appointmentItem.top) >
                          allDayRect.height) {
                    var allDayOffset =
                        allDayRect.height - widget.appointmentItem.top;
                    dragDelta =
                        Offset(dragDelta.dx, dragDelta.dy - allDayOffset);
                    isAllDay = false;
                    renderService = viewService.allDayHostRenderService!;
                  }
                }
                List newDates = renderService.datesOfPosChange(
                    widget.appointmentItem, dragDelta);
                scheduler.dataSource!.rescheduleAppointment(
                    appointment, newDates[0], newDates[1], isAllDay);
              } else {
                var dragSizeDirection =
                    appointmentDragService.dragSizeDirection;
                List newDates = widget.appointmentRenderService
                    .datesOfSizeChange(
                        widget.appointmentItem, dragDelta, dragSizeDirection);
                scheduler.dataSource!.rescheduleAppointment(appointment,
                    newDates[0], newDates[1], appointment.isAllDay);
              }
            }
          } else {
            dragDelta = Offset.zero;
          }
        },
        data: widget.appointmentItem.appointment,
        //childWhenDragging: widget.viewBuilder(dragging: true),
        feedback: ValueListenableBuilder(
          valueListenable: AppointmentDragService().dragModeNotifier,
          builder: (BuildContext context, DragMode mode, Widget? child) =>
              mode == DragMode.size
                  ? Container()
                  : ValueListenableBuilder(
                      valueListenable:
                          AppointmentDragService().appointmentDragCancel,
                      builder: (BuildContext context, bool canceled,
                              Widget? child) =>
                          canceled
                              ? Container()
                              : Material(
                                  color: Colors.transparent,
                                  child: widget.viewBuilder(
                                    opacity: 0.75,
                                    dragging: true,
                                  ),
                                ),
                    ),
        ),
        child: widget.child,
      ),
    );
  }
}
