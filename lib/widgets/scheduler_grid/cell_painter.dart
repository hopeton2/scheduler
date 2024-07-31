import 'package:flutter/material.dart';

import '../../scheduler.dart';
import '../../services/scheduler_service.dart';
import '../../services/services.dart';
import 'grid_cell.dart';

class CellPainter extends CustomPainter with ChangeNotifier {
  final GridCell cell;
  final BuildContext context;
  CellPainter({
    required this.cell,
    required this.context,
  });

  bool _isHovered = false;
  bool get isHovered => _isHovered;

  set isHovered(bool value){
    if (value != isHovered) {
      _isHovered = value;
      notifyListeners();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    SchedulerSettings settings = SchedulerService.instance.schedulerSettings;
    Rect rect = Rect.fromPoints(Offset.zero, Offset(cell.size.width, cell.size.height));
    Color color = isHovered ? settings.getCellHoverBorderColor(context) : settings.getIntervalLineColor(context);

    Paint paint = Paint()
      ..color = color
      ..strokeWidth = settings.dividerLineWidth
      ..style = PaintingStyle.stroke;

    if (isHovered) {
      canvas.drawRect(rect, paint);
    } else if(cell.showLines) {
      if (!cell.showDashLines || cell.rowIndex % cell.intervalBlockSize == 0) {
        canvas.drawLine(rect.bottomLeft, rect.bottomRight, paint);
      } else {
        drawDashLine(canvas, size);
      }
      canvas.drawLine(rect.topLeft, rect.bottomLeft, paint);
    }

    if (cell.showCellDate && cell.date != null && cell.headerBuilder == null) {
      drawDate(canvas, size);
    }
    cell.rect = rect;
  }

  @override
  bool shouldRepaint(covariant CellPainter oldDelegate) {
    return oldDelegate.isHovered != isHovered;
  }

  void drawDate(Canvas canvas, Size size) {
    final textSpan = TextSpan(text: cell.getFormattedDate(), style: cell.getTextStyle());
    final textPainter = TextPainter(
      textWidthBasis: TextWidthBasis.parent,
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - textPainter.width-5, 0));
  }

  void drawDashLine(Canvas canvas, Size size) {
    double dashWidth = 3, dashSpace = 1, startX = 1;
    final paint = Paint()
      ..color = schedulerService.schedulerSettings.getIntervalLineColor(context).withOpacity(0.1)
      ..strokeWidth = schedulerService.schedulerSettings.dividerLineWidth;
    while (startX < size.width-1) {
      canvas.drawLine(Offset(startX, size.height), Offset(startX + dashWidth, size.height), paint);
      startX += dashWidth + dashSpace;
    }
  }
}
