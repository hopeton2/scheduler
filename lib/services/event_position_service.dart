import 'dart:ui';

import 'package:dart_date/dart_date.dart';
import 'package:scheduler/extensions/ui_extensions.dart';

import '../mixins/event_layout_mixin.dart';
import '../models/appointment_item.dart';

class EventPositionService with EventLayoutMixin {
  static final instance = EventPositionService._internal();
  EventPositionService._internal();


  void positionHorizontalEvents(List<AppointmentItem> appointmentItems, double margin, {Rect? clientRect}) {
    for (var event in appointmentItems) {
      _repositionHorizontalOverlaps(event, appointmentItems, margin);
      //--adjusted rect to account for the "more" button at the bottom

      if (clientRect != null) {
        clientRect = clientRect.shrink(const Offset(0,1));
        if (!clientRect.contains(event.rect.bottomRight)) {
          event.rect = Rect.zero;
        }
      }
    }
  }

  _repositionHorizontalOverlaps(AppointmentItem appointmentItem, List<AppointmentItem> appointmentItems, double margin) {
    var index = appointmentItems.indexOf(appointmentItem);
    for (int i = 0; i < index; i++) {
      var item = appointmentItems[i];
      if (item.rect.overlaps(appointmentItem.rect)) {
        appointmentItem.top = item.rect.bottom + margin;
        _repositionHorizontalOverlaps(appointmentItem, appointmentItems, margin);

        return;
      }
    }
  }

  void positionVerticalEvents(List<AppointmentItem> appointments, Rect clientRect, double margin) {
    List<List<AppointmentItem>> columns = [];
    DateTime? lastEventEnding;

    // Order by startDate, then by endDate
    appointments.sort((a, b) => a.startDate.compareTo(b.startDate) != 0 ? a.startDate.compareTo(b.startDate) : a.endDate.compareTo(b.endDate));

    for (var appointment in appointments) {
      if (lastEventEnding != null && appointment.startDate.isAfter(lastEventEnding)) {
        packEvents(columns, clientRect, margin);
        columns.clear();
        lastEventEnding = null;
      }
      bool placed = false;
      for (var column in columns) {
        if (!collidesWith(column.last, appointment)) {
          column.add(appointment);
          placed = true;
          break;
        }
      }
      if (!placed) {
        columns.add([appointment]);
      }
      if (lastEventEnding == null || appointment.endDate.isAfter(lastEventEnding)) {
        lastEventEnding = appointment.endDate.subSeconds(1);
      }
    }
    if (columns.isNotEmpty) {
      packEvents(columns, clientRect, margin);
    }
  }

  void packEvents(List<List<AppointmentItem>> columns, Rect clientRect, double margin) {
    int numColumns = columns.length;
    int iColumn = 0;

    for (var appointments in columns) {
      for (var appointment in appointments) {
        int colSpan = expandEvent(appointment, iColumn, columns);
        appointment.left = clientRect.left + ((iColumn / numColumns) * clientRect.width);
        appointment.width = (clientRect.width * colSpan / numColumns-1) - margin;
      }
      iColumn++;
    }
  }

  int expandEvent(AppointmentItem appointment, int iColumn, List<List<AppointmentItem>> columns) {
    int colSpan = 1;
    for (var column in columns.skip(iColumn + 1)) {
      for (var otherAppointment in column) {
        if (collidesWith(otherAppointment, appointment)) {
          return colSpan;
        }
      }
      colSpan++;
    }

    return colSpan;
  }

  bool collidesWith(AppointmentItem a, AppointmentItem b) {
    return a.endDate.isAfter(b.startDate) && a.startDate.isBefore(b.endDate);
  }


}

