import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scheduler/services/appointment_drag_service.dart';

import '../common/scheduler_view_helper.dart';
import '../services/scheduler_service.dart';
import '../services/ui_service.dart';

class ScrollableStack extends StatelessWidget {
  final List<Widget> children;
  final ScrollController scrollController;
  ScrollableStack({
    super.key,
    required this.children,
    required this.scrollController,
  }) {
    UIService.instance.topMostContainer = this;
    SchedulerService.instance.scrollController = scrollController;
  }

  @override
  Widget build(BuildContext context) {
    UIService.instance.topMostContext = context;

    return Listener(
      onPointerDown: (event) {
        _setActiveScrollController();
      },
      onPointerMove: (event) {
        if (event.down && !SchedulerViewHelper.isMobileLayout(context)) {
          _scrollPastViewPortWhenNeeded(event);
        }
      },
      child: ValueListenableBuilder(
        valueListenable: UIService.instance.topMostNotifier,
        builder: (BuildContext context, Widget? widget, Widget? child) {
          //var widgets = children;
          if (widget != null) {
            children.remove(widget);
            children.add(widget);
          }

          return Stack(
            children: children,
          );
        },
      ),
    );
  }

  void _setActiveScrollController() {
    AppointmentDragService().activeScrollController = scrollController;
    SchedulerService.instance.scrollController = scrollController;
  }

  void _scrollPastViewPortWhenNeeded(PointerMoveEvent event) {
    int boundaryOffset = 25;
    double jumpBy = 5;
    double jumpValue = 0;
    double scrollPos = scrollController.position.axis == Axis.vertical
        ? event.localPosition.dy
        : event.localPosition.dx;
    double localDelta = scrollController.position.axis == Axis.vertical
        ? event.localDelta.dy
        : event.localDelta.dx;
    jumpBy += localDelta;
    if (scrollPos >=
        scrollController.position.viewportDimension - boundaryOffset) {
      jumpValue = min(
        scrollController.position.maxScrollExtent,
        scrollController.offset + jumpBy,
      );
      scrollController.jumpTo(jumpValue);
    }
    if (scrollPos <= boundaryOffset) {
      jumpValue = max(0, scrollController.offset - jumpBy);
      scrollController.jumpTo(jumpValue);
    }
  }
}
