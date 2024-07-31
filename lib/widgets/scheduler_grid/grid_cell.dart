import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../draggable_cursor.dart';
import '../../scheduler.dart';
import '../../services/appointment_drag_service.dart';
import '../../services/services.dart';
import 'cell_painter.dart';

class GridCell extends StatelessWidget {
  final Size size;
  final DateTime? date;
  final String? dateFormat;
  final TextStyle? textStyle;
  final int rowIndex;
  final int colIndex;
  final int intervalBlockSize;
  final bool showLines;
  final bool showDashLines;
  final bool showCellDate;
  final PainterBuilder? headerBuilder;
  GridCell({
    super.key,
    this.date,
    this.dateFormat,
    this.textStyle,
    this.showLines = true,
    required this.size,
    required this.rowIndex,
    required this.colIndex,
    required this.intervalBlockSize,
    required this.showDashLines,
    this.headerBuilder,
    this.showCellDate = true,
  });

  String getFormattedDate() {
    return intl.DateFormat(getDateFormat()).format(date!);
  }

  String getDateFormat() {
    return dateFormat ?? intl.DateFormat.HOUR_MINUTE;
  }

  TextStyle getTextStyle() {
    Color? color = schedulerService.schedulerSettings.timebarFontColor;

    return textStyle ?? TextStyle(fontSize: 10, color: color);
  }

  Rect rect = Rect.zero;

  @override
  Widget build(BuildContext context) {
    CellPainter cellPainter = CellPainter(cell: this, context: context);

    return Listener(
      onPointerUp: (_) {
        if (schedulerService.scheduler.controller.viewType != CalendarViewType.day && date != null) {
            schedulerService.scheduler.controller.selectInOneDay(date!);
        }
      },
      onPointerDown: (_) {
         schedulerService.scheduler.controller.canSelectAndJumpToDayView = true;
      },
      child: MouseRegion(
        cursor: DraggableCursor(),
    
        onHover: (event) {
          if (event.kind == PointerDeviceKind.mouse) {
            if (!AppointmentDragService().isDragging) {
              cellPainter.isHovered = true;
            }
          }
        },
        onExit: (event) {
          cellPainter.isHovered = false;
        },
        child: CustomPaint(
          size: size,
          painter: cellPainter,
          foregroundPainter: headerBuilder != null && date != null ? headerBuilder!(context) : null,
        ),
      ),
    );
  }
}


