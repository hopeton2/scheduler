import 'package:flutter/material.dart';
import 'package:scheduler/scheduler.dart';
import 'grid_cell.dart';
import 'grid_row.dart';
import 'grid_helper.dart';

class SchedulerGrid extends StatelessWidget {
  final IntervalType intervalType;
  final List<DateTime> gridDates;
  final Axis orientation;
  final int colCount;
  final int rowCount;
  final Size cellSize;
  final HeaderPosition headerPosition;
  final int slotsPerTimeBlock;
  final Rect clientRect;
  final ScrollController scrollController;
  final HeaderBuilder? columnHeaderBuilder;
  final HeaderBuilder? rowHeaderBuilder;
  final bool showDashLines;
  final GridHelper gridHelper;

  const SchedulerGrid({
    super.key,
    required this.headerPosition,
    required this.cellSize,
    required this.gridDates,
    required this.intervalType,
    required this.orientation,
    required this.colCount,
    required this.rowCount,
    required this.slotsPerTimeBlock,
    required this.clientRect,
    required this.scrollController,
    required this.gridHelper,
    this.showDashLines = true,
    this.rowHeaderBuilder,
    this.columnHeaderBuilder,
  });

  GridRow _addGridRow(int index, DateTime intervalDate) {
    GridRow row = GridRow(
      showDashLines: showDashLines,
      headerBuilder: rowHeaderBuilder,
      intervalBlockSize: slotsPerTimeBlock,
      cellCount: colCount,
      cellSize: cellSize,
      rowIndex: index,
      initialDate: intervalDate,
      gridHelper: gridHelper,
      onAddCell: (GridCell cell) {
        gridHelper.cells.add(cell);
      },
    );
    return row;
  }

  @override
  Widget build(BuildContext context) {
    gridHelper.cells.clear();
    return ListView.builder(
      primary: false,
      controller: scrollController,
      itemCount: rowCount,
      itemBuilder: (context, index) {
        final intervalDate = gridHelper.incrementRowDate(index);

        return Stack(children: [
          _addGridRow(index, intervalDate),
        ]);
      },
    );
  }
}
