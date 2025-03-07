import 'package:flutter/material.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/fab_service.dart';
import 'package:scheduler/services/scheduler_service.dart';

class FabProvider extends StatelessWidget {
  final Widget child;

  const FabProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: child,
      floatingActionButton: ValueListenableBuilder(
          valueListenable:
              SchedulerService().scheduler.controller.startDateChangeNotify,
          builder: (context, DateTime startDate, _) {
            return isDesktop
                ? FabService.instance
                    .createExtendedFab(context, date: startDate)
                : FabService.instance.createFab(context, date: startDate);
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
