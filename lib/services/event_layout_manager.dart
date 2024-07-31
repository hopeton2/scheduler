
import 'package:dart_date/dart_date.dart';
import 'package:flutter/rendering.dart';
import 'package:list_ext/list_ext.dart';
import 'package:scheduler/extensions/ui_extensions.dart';

import '../models/appointment_item.dart';
import '../widgets/scheduler_grid/grid_helper.dart';
import 'appointment_render_service.dart';
import 'event_position_service.dart';
import 'scheduler_service.dart';
import 'services.dart';

class EventLayoutManager {
  final List<AppointmentItem> events;
  final DateTime initialDate;
  final Rect calendarRect;
  final double fixedSize;
  final Axis orientation;
  final int colCount;
  final int rowCount;
  final double cellTopOffset;
  final double rightMarginOffset;
  final AppointmentRenderService renderService;
  final GridHelper gridHelper;
  final ({DateTime start, DateTime end}) Function(DateTime date, int index) incCellDate;
  EventLayoutManager({
    required this.initialDate,
    required this.events,
    required this.calendarRect,
    required this.orientation,
    required this.colCount,
    required this.rowCount,
    required this.gridHelper,
    this.fixedSize = 0,
    this.cellTopOffset = 45,
    this.rightMarginOffset = 10,
    required this.incCellDate,
    required this.renderService

  }) {
    instanceIndex++;
    renderService.eventLayoutManager = this;
    _createLayoutCells();
  }

  final List<LayoutTimeCell> layoutCells = [];
  static int instanceIndex = 0;

  LayoutTimeCell? cellAtPos(Offset position){
    //if (layoutCells.isNotEmpty) {
    //  _createLayoutCellsFromGridCells();
    //}
     return layoutCells.firstWhereOrNull((cell) => cell.rect.contains(position));
  }

  double get margin => SchedulerService.instance.appointmentSettings.spaceBetween;

  Size get cellSize => Size(calendarRect.width / colCount, calendarRect.height / rowCount);

  _createLayoutCellsFromGridCells() {
     layoutCells.clear();
     for (var cell in gridHelper.cells) { 
        layoutCells.add(LayoutTimeCell(cell.colIndex, cell.rowIndex, cell.date!.startOfDay, cell.date!.endOfDay, cell.rect.move(x:65)));
     }
  }
 
  _createLayoutCells() {
    int index = 0;
    for (int row = 0; row < rowCount; row++) {
      for (int col = 0; col < colCount; col++) {
        Rect rect = Rect.fromLTWH(
          col * cellSize.width + calendarRect.left,
          row * cellSize.height,
          cellSize.width,
          cellSize.height,
        );
        var dates = incCellDate(initialDate, index);
        layoutCells.add(LayoutTimeCell(col, row, dates.start, dates.end, rect));
        index++;
      }
    }
  }

  List<AppointmentItem> arrangeEvents() {
    sizeEvents();
    positionEvents();

    return events;
  }

  sizeEvents() {
    for (var event in events) {
      event.rect = Rect.zero;
      LayoutTimeCell? startingCell = layoutCells.firstWhereOrNull(
          (cell) => cell.startDate.startOfDay == event.startDate.startOfDay,);
      LayoutTimeCell? endingCell = layoutCells.firstWhereOrNull(
          (cell) => cell.startDate.startOfDay == event.endDate.startOfDay,);
      if (startingCell != null && endingCell != null) {
        Rect rect = Rect.fromLTWH(
          startingCell.rect.left + 1,
          startingCell.rect.top + cellTopOffset,
          endingCell.rect.right - startingCell.rect.left - rightMarginOffset,
          fixedSize,
        );
        event.rect = rect;
      }
    }
  }

  positionEvents() {
    if (orientation == Axis.vertical) {
      EventPositionService.instance.positionVerticalEvents(events, calendarRect, margin);
    } else {
      for (int row = 0; row < rowCount; row++) {
        List<LayoutTimeCell> rowCells = layoutCells.where((cell) => cell.row == row).toList();
        Rect rowRect = Rect.fromLTRB(
          calendarRect.left,
          rowCells.first.rect.top,
          calendarRect.right,
          rowCells.last.rect.bottom,
        );
        List<AppointmentItem> rowEvents = events.where((event) => event.rect.overlaps(rowRect)).toList();
        rowEvents.sort((a, b) {
          int startDateComparison = a.startDate.startOfDay.compareTo(b.startDate.startOfDay);
          if (startDateComparison != 0) {
            return startDateComparison;
          }

         return b.endDate.compareTo(a.endDate);
        });
        EventPositionService.instance.positionHorizontalEvents(rowEvents, margin, clientRect: rowRect);
      }
    }
  }
}

class LayoutTimeCell {
  final int column;
  final int row;
  final DateTime startDate;
  final DateTime endDate;
  final Rect rect;
  LayoutTimeCell(this.column, this.row, this.startDate, this.endDate, this.rect);
}
