import 'package:flutter/material.dart';
import 'package:scheduler/interval_config.dart';

import '../../scheduler.dart';
import 'grid_cell.dart';
import 'grid_helper.dart';

class GridRow extends StatelessWidget with IntervalConfig {
  final DateTime initialDate;
  final int rowIndex;
  final int cellCount;
  final Size cellSize;
  final int intervalBlockSize;
  final HeaderBuilder? headerBuilder;
  final bool showDashLines;
  final GridHelper gridHelper;
  final void Function(GridCell cell)? onAddCell;
  GridRow({
    super.key,
    required this.initialDate,
    required this.rowIndex,
    required this.cellCount,
    required this.cellSize,
    required this.intervalBlockSize,
    required this.showDashLines,
    required this.gridHelper,
    this.headerBuilder,
    this.onAddCell,
  });

  DateTime? _getCellDate(int colIndex) {
    if (gridHelper.incrementCellDate != null) {
      return gridHelper.incrementCellDate!(initialDate, colIndex);
    }
    if (gridHelper.cellHeaderBuilder != null) {
      return incrementIntervalGroupDate(initialDate, multiplier: colIndex);
    }
    return null;
  }


  GridCell _addCell(int colIndex) {
    GridCell cell = GridCell(
      headerBuilder: gridHelper.cellHeaderBuilder,
      date: _getCellDate(colIndex),
      showDashLines: showDashLines,
      size: cellSize,
      rowIndex: rowIndex,
      colIndex: colIndex,
      intervalBlockSize: intervalBlockSize,
      showCellDate: gridHelper.showCellDate,
      dateFormat: gridHelper.cellDateFormat,
    );

    if (onAddCell != null) {
      onAddCell!(cell);
    }
    return cell;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (headerBuilder != null)
          headerBuilder!(context, initialDate, rowIndex),
        for (int i = 0; i < cellCount; i++) _addCell(i)
      ],
    );
  }
}
