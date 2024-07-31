import 'dart:ui';

import '../../scheduler.dart';
import 'grid_cell.dart';

class GridHelper {
    final DateTime Function(int index) incrementRowDate;
    final DateTime Function(DateTime date, int index)? incrementCellDate;
    final PainterBuilder? cellHeaderBuilder;
    final bool showCellDate;
    final String? cellDateFormat;

    GridHelper({
      required this.incrementRowDate,
      this.incrementCellDate,
      this.cellHeaderBuilder,
      this.cellDateFormat,
      this.showCellDate = true,
    });

    List<GridCell> cells = [];
}