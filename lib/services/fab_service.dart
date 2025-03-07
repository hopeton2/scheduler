import 'package:flutter/material.dart';
import 'package:scheduler/widgets/appointment/appointment_editor.dart';

class FabService {
  static final FabService instance = FabService._internal();
  FabService._internal();

  // Method to show the appointment editor dialog
  void showAppointmentEditor(
    BuildContext context, {
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    bool isAllDay = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AppointmentEditor(
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
        isAllDay: isAllDay,
      ),
    );
  }

  // Method to create a floating action button
  Widget createFab(BuildContext context, {DateTime? date}) {
    return FloatingActionButton(
      onPressed: () => showAppointmentEditor(
        context,
        initialStartDate: date,
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.add),
      tooltip: 'Add Appointment',
    );
  }

  // Method to create an extended floating action button with label
  Widget createExtendedFab(BuildContext context, {DateTime? date}) {
    return FloatingActionButton.extended(
      onPressed: () => showAppointmentEditor(
        context,
        initialStartDate: date,
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      label: const Text('Add Appointment'),
      icon: const Icon(Icons.add),
      tooltip: 'Add Appointment',
    );
  }
}
