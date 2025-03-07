import 'package:flutter/material.dart';
import 'package:scheduler/common/scheduler_view_helper.dart';
import 'package:scheduler/widgets/appointment_editor/appointment_editor.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/scheduler_service.dart';

class CreateEventButton extends StatelessWidget {
  const CreateEventButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAppointmentEditor(context),
      child: const Icon(Icons.add),
    );
  }

  void _showAppointmentEditor(BuildContext context) async {
    final isMobile = SchedulerViewHelper.isMobileLayout(context);
    
    final appointment = await (isMobile
        ? Navigator.of(context).push<Appointment>(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => const AppointmentEditor(),
            ),
          )
        : showDialog<Appointment>(
            context: context,
            builder: (context) => const AppointmentEditor(),
          ));

    if (appointment != null) {
      // Add the appointment to the scheduler's data source
      final scheduler = SchedulerService.instance.scheduler;
      scheduler.dataSource?.appointments.add(appointment);
    }
  }
}
