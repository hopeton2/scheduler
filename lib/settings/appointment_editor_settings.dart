import 'package:flutter/material.dart';

/// Settings class for customizing appointment editor text and formatting
class AppointmentEditorSettings {
  // Dialog titles and buttons
  final String newAppointmentTitle;
  final String editAppointmentTitle;
  final String saveButtonLabel;
  final String cancelButtonLabel;
  final String deleteButtonLabel;

  // Subject field
  final String subjectFieldLabel;
  final String subjectEmptyErrorMessage;

  // All day section
  final String allDayLabel;

  // Date and time section
  final String startDateLabel;
  final String endDateLabel;
  final String startTimeLabel;
  final String endTimeLabel;

  // Color section
  final String colorLabel;

  // Date formats
  final String dateFormat;
  final String timeFormat;
  final String dateTimeFormat;

  const AppointmentEditorSettings({
    this.newAppointmentTitle = 'New Appointment',
    this.editAppointmentTitle = 'Edit Appointment',
    this.saveButtonLabel = 'Save',
    this.cancelButtonLabel = 'Cancel',
    this.deleteButtonLabel = 'Delete',
    this.subjectFieldLabel = 'Subject',
    this.subjectEmptyErrorMessage =
        'Please enter a subject for the appointment',
    this.allDayLabel = 'All Day',
    this.startDateLabel = 'Start Date',
    this.endDateLabel = 'End Date',
    this.startTimeLabel = 'Start Time',
    this.endTimeLabel = 'End Time',
    this.colorLabel = 'Color',
    this.dateFormat = 'EEE, MMM d, yyyy',
    this.timeFormat = 'h:mm a',
    this.dateTimeFormat = 'yyyy-MM-dd HH:mm',
  });
}
