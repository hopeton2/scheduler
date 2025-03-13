
import 'package:flutter/material.dart';

/// Settings class for customizing appointment editor text and formatting
class AppointmentEditorSettings {
  // Dialog titles and buttons
  final String newAppointmentTitle;
  final String editAppointmentTitle;
  final String saveButtonLabel;
  final String cancelButtonLabel;
  final String deleteButtonLabel;
  final String deleteConfirmationTitle;
  final String deleteConfirmationMessage;

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
  final String customColorLabel;
  final List<Color> predefinedColors;
  final ColorPickerStyle colorPickerStyle;

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
    this.deleteConfirmationTitle = 'Delete Appointment',
    this.deleteConfirmationMessage = 'Are you sure you want to delete this appointment?',
    this.subjectFieldLabel = 'Subject',
    this.subjectEmptyErrorMessage = 'Please enter a subject for the appointment',
    this.allDayLabel = 'All Day',
    this.startDateLabel = 'Start Date',
    this.endDateLabel = 'End Date',
    this.startTimeLabel = 'Start Time',
    this.endTimeLabel = 'End Time',
    this.colorLabel = 'Color',
    this.customColorLabel = 'Custom Color',
    this.dateFormat = 'EEE, MMM d, yyyy',
    this.timeFormat = 'h:mm a',
    this.dateTimeFormat = 'yyyy-MM-dd HH:mm',
    this.predefinedColors = const [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
      Colors.brown,
      Colors.deepOrange,
    ],
    this.colorPickerStyle = ColorPickerStyle.dropdown,  // dropdown is now the default
  });
}

enum ColorPickerStyle {
  /// Shows colors in a dropdown/dialog
  dropdown,
  
  /// Shows colors in a grid directly in the editor
  grid
}
