import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../constants.dart';
import '../../scheduler.dart';
import '../../services/scheduler_service.dart';
import '../../services/services.dart';
import '../../widgets/scheduler_grid/cell_painter.dart';

class MonthCellHeader extends CellPainter {
  final DateTime startDate;
  int currentMonth;
  MonthCellHeader({required super.cell, required super.context, required this.startDate, required this.currentMonth,});

  @override
  void paint(Canvas canvas, Size size) {
    drawDate(canvas, size);
  }

  @override
  void drawDate(Canvas canvas, Size size) {
    MonthViewSettings settings = SchedulerService.instance.monthViewSettings;
    SchedulerSettings schedulerSettings = SchedulerService.instance.schedulerSettings;
    ThemeData theme = Theme.of(context);
    DateTime date = cell.date!;
    bool isLongDate = date == startDate || date.isFirstDayOfMonth;
    bool isSelected = schedulerService.scheduler.controller.selectedDates.contains(date);
    Color? fontColor = date.isToday ? schedulerSettings.currentDateFontColor ??
        theme.colorScheme.onPrimary : schedulerSettings.getBackgroundFontColor(context);

    Color? getFontColor(DateTime date) {
      if (isSelected) {
        return theme.colorScheme.onPrimary;
      } 

     if (date.isToday) {
       return theme.colorScheme.primary;
     } 

      if (date.month == currentMonth) {
        return fontColor;
      }

      return date.month < currentMonth
          ? settings.leadingDaysTextStyle != null
          ? settings.leadingDaysTextStyle!.color
          : fontColor
          : settings.trailingDaysTextStyle != null
          ? settings.trailingDaysTextStyle!.color
          : fontColor;
    }

    String monthDateFormat() {
      String result = 'd';
      if (isLongDate) {
        result = 'MMM d';
        if (MediaQuery.of(context).size.width <= kSmallDevice) {
          result = 'Md';
        }
      }

      return result;
    }

   final textSpan = TextSpan(
      text: intl.DateFormat(monthDateFormat()).format(date),
      style: TextStyle(color: getFontColor(date)),
    );

    final textPainter = TextPainter(
      textWidthBasis: TextWidthBasis.parent,
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final center = Offset(size.width / 2, 20);
    const radius = 15.0;

    textPainter.layout();
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );

    if (date.isToday || isSelected) {
      Paint paint = Paint()
      ..strokeWidth = 1
      ..style = isSelected ? PaintingStyle.fill : PaintingStyle.stroke
      ..color = schedulerSettings.currentDateBackgroundColor ?? theme.colorScheme.primary;
      if (isLongDate) {
        final Rect rect =  Rect.fromLTWH(center.dx - 10 - textPainter.width / 2, center.dy - textPainter.height, textPainter.width + 20, textPainter.height * 2);
        const Radius radius = Radius.circular(10);
        final roundedRect = RRect.fromRectAndRadius(rect, radius);
        canvas.drawRRect(roundedRect, paint);
        //canvas.drawOval(Rect.fromLTWH(center.dx - 10 - textPainter.width / 2, center.dy - textPainter.height, textPainter.width + 20, textPainter.height * 2), paint);
      } else {
        canvas.drawCircle(center, radius, paint );
      }
    }

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
