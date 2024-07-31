import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/scheduler_service.dart';

class TimeCell extends StatelessWidget {
  final HeaderPosition headerPosition;
  final Size headerSize;
  final DateTime cellDate;
  final Axis direction;
  final Size size;
  final bool lineVisible;
  final bool headerVisible;
  final Widget? header;
  const TimeCell({
    Key? key,
    required this.headerPosition,
    required this.direction,
    required this.size,
    required this.cellDate,
    required this.headerSize,
    this.lineVisible = true,
    this.headerVisible = false,
    this.header,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final schedulerSettings = SchedulerService().schedulerSettings;

    return Expanded(
      child: Flex(direction: Axis.horizontal, children: [
        Visibility(visible: headerVisible, child: header ?? cellHeader()),
        Container(
          width: size.width,
          //height: size.height,
          decoration: !lineVisible
              ? null
              : DottedDecoration(
                  dash: const [1, 2],
                  color: schedulerSettings.getIntervalLineColor(context),
                  strokeWidth: schedulerSettings.dividerLineWidth,
                  shape: Shape.line,
                  linePosition: direction == Axis.vertical
                      ? LinePosition.top
                      : LinePosition.left,
                ),
        ),
      ]),
    );
  }

  Widget cellHeader() {
    return Container(width: headerSize.width, color: Colors.grey);
  }
}
