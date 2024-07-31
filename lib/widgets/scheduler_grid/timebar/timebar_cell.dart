import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/context_holder.dart';
import '../../../services/services.dart';
import '../cell_painter.dart';
import '../grid_cell.dart';

class TimebarCell extends GridCell {
  final Axis direction;
  TimebarCell({
    required this.direction,
    required super.rowIndex,
    required super.colIndex,
    required super.intervalBlockSize,
    super.key,
    super.date,
    super.dateFormat,
    super.showLines = false,
    super.showDashLines = false,
    required super.size,
  });

  final ContextHolder contextHolder = ContextHolder();

  @override
  String getDateFormat() {
    if (rowIndex % intervalBlockSize == 0) {
      return DateFormat.HOUR;
    }

    return DateFormat.MINUTE;
  }

  @override
  TextStyle getTextStyle() {
    Color? color = schedulerService.schedulerSettings.getTimebarFontColor(contextHolder.context!);

    return textStyle ?? TextStyle(fontSize: 10, color: color);
  }

  @override
  Widget build(BuildContext context) {
    contextHolder.context = context;

    return CustomPaint(
      size: size,
      painter: CellPainter(cell: this, context: context),
    );
  }
}
