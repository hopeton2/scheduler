import 'package:flutter/material.dart';
import 'package:dart_date/dart_date.dart';
import 'package:intl/intl.dart';
import 'package:scheduler/extensions/date_extensions.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/scheduler_service.dart';
import 'package:scheduler/services/recurrence_service.dart';
import 'package:scheduler/widgets/appointment/recurrence_editor.dart';

class AppointmentEditor extends StatefulWidget {
  final Appointment? appointment;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final bool isAllDay;

  const AppointmentEditor({
    super.key,
    this.appointment,
    this.initialStartDate,
    this.initialEndDate,
    this.isAllDay = false,
  });

  @override
  State<AppointmentEditor> createState() => _AppointmentEditorState();
}

class _AppointmentEditorState extends State<AppointmentEditor> {
  late TextEditingController _subjectController;
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _isAllDay;
  late Color _selectedColor;
  String? _recurrenceRule;

  final List<Color> _colors = [
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
  ];

  // Get settings once and store for efficiency
  late final _editorSettings =
      SchedulerService().scheduler.appointmentEditorSettings;
  late final _recurrenceSettings =
      SchedulerService().scheduler.recurrenceSettings;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(
      text: widget.appointment?.subject ?? '',
    );
    _startDate = widget.initialStartDate ??
        widget.appointment?.startDate ??
        DateTime.now().roundToNearest(const Duration(minutes: 15));
    _endDate = widget.initialEndDate ??
        widget.appointment?.endDate ??
        _startDate.add(SchedulerService().appointmentSettings.defaultDuration);
    _isAllDay = widget.isAllDay || (widget.appointment?.isAllDay ?? false);
    _selectedColor = widget.appointment?.color ?? _colors[0];
    _recurrenceRule = widget.appointment?.recurrenceRule;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  void _saveAppointment() {
    if (_subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editorSettings.subjectEmptyErrorMessage)),
      );
      return;
    }

    final dataSource = SchedulerService.instance.scheduler.dataSource;
    final appointment = widget.appointment;

    if (appointment != null) {
      // Update existing appointment
      dataSource!
          .rescheduleAppointment(appointment, _startDate, _endDate, _isAllDay);
      appointment.subject = _subjectController.text;
      appointment.color = _selectedColor;
      appointment.recurrenceRule = _recurrenceRule;
      dataSource.updateListeners();
    } else {
      // Create new appointment
      dataSource!.addAppointment(
        _startDate,
        _endDate.difference(_startDate),
        _subjectController.text,
        color: _selectedColor,
        isAllDay: _isAllDay,
        recurrenceRule: _recurrenceRule,
      );
    }

    Navigator.of(context).pop();
  }

  // Confirm deletion for recurring appointments
  void _handleDelete() {
    final appointment = widget.appointment;

    if (appointment?.recurrenceRule != null &&
        appointment!.recurrenceRule!.isNotEmpty) {
      // For recurring appointment, show confirmation dialog
      _showRecurrenceDeleteOptionsDialog();
    } else {
      // For regular appointment, delete directly
      _deleteAppointment();
    }
  }

  void _showRecurrenceDeleteOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_recurrenceSettings.deleteRecurrenceTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_recurrenceSettings.deleteRecurrenceMessage),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteOccurrence();
                    },
                    child: Text(_recurrenceSettings.thisOccurrenceLabel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteAppointment(); // Delete the entire series
                    },
                    child: Text(_recurrenceSettings.entireSeriesLabel),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Delete just this occurrence by creating an exception in the recurrence pattern
  void _deleteOccurrence() {
    // Currently there isn't a built-in way to delete a single occurrence
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(_recurrenceSettings.deleteOccurrenceUnimplementedMessage)),
    );
    Navigator.of(context).pop();
  }

  // Delete the entire appointment
  void _deleteAppointment() {
    if (widget.appointment != null) {
      SchedulerService.instance.scheduler.dataSource!
          .deleteAppointment(widget.appointment!);
    }
    Navigator.of(context).pop();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime initialDate = isStart ? _startDate : _endDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().addYears(-1),
      lastDate: DateTime.now().addYears(5),
    );

    if (picked != null) {
      DateTime selectedDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        isStart ? _startDate.hour : _endDate.hour,
        isStart ? _startDate.minute : _endDate.minute,
      );

      setState(() {
        if (isStart) {
          _startDate = selectedDateTime;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(hours: 1));
          }
        } else {
          _endDate = selectedDateTime;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(hours: 1));
          }
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay initialTime = isStart
        ? TimeOfDay(hour: _startDate.hour, minute: _startDate.minute)
        : TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = DateTime(
            _startDate.year,
            _startDate.month,
            _startDate.day,
            picked.hour,
            picked.minute,
          );

          // If start time is now after end time, adjust end time
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate.add(const Duration(hours: 1));
          }
        } else {
          _endDate = DateTime(
            _endDate.year,
            _endDate.month,
            _endDate.day,
            picked.hour,
            picked.minute,
          );

          // If end time is now before start time, adjust start time
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate.subtract(const Duration(hours: 1));
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.appointment != null;
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.7; // 70% of screen height

    // Check if appointment has recurrence
    final bool hasInitialRecurrence = RecurrenceService.instance.hasRecurrence(
        widget.appointment ?? Appointment(_startDate, _endDate, ''));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 20, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 600 : double.infinity,
          maxHeight: maxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top app bar with save and cancel buttons
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: Text(_editorSettings.cancelButtonLabel,
                          style: const TextStyle(color: Colors.white)),
                    ),
                    Text(
                      isEditing
                          ? _editorSettings.editAppointmentTitle
                          : _editorSettings.newAppointmentTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _saveAppointment,
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: Text(_editorSettings.saveButtonLabel,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),

            // Content area with scrolling
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject field
                    TextField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        labelText: _editorSettings.subjectFieldLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        prefixIcon: const Icon(Icons.subject),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // All day toggle
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _editorSettings.allDayLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _isAllDay,
                          onChanged: (value) {
                            setState(() {
                              _isAllDay = value;
                              if (value) {
                                _startDate = _startDate.startOfDay;
                                _endDate = _endDate.endOfDay;
                              } else {
                                _startDate = _startDate.copyWith(
                                    hour: DateTime.now().hour);
                                _endDate =
                                    _startDate.add(const Duration(hours: 1));
                              }
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Date and time selectors for start
                    _buildDateTimeSelectors(isDesktop),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Recurrence section (now using the RecurrenceEditor widget)
                    RecurrenceEditor(
                      baseDate: _startDate,
                      initialRecurrenceRule: _recurrenceRule,
                      initiallyExpanded: hasInitialRecurrence,
                      onRecurrenceChanged: (String? recurrenceRule) {
                        _recurrenceRule = recurrenceRule;
                      },
                    ),

                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Color picker
                    Text(_editorSettings.colorLabel,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _colors.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: _selectedColor == color
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                              boxShadow: [
                                if (_selectedColor == color)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                              ],
                            ),
                            child: _selectedColor == color
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    if (isEditing)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          icon: const Icon(Icons.delete),
                          label: Text(_editorSettings.deleteButtonLabel),
                          onPressed: _handleDelete,
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New method to build date/time selectors without LayoutBuilder and without the duplicate All Day label
  Widget _buildDateTimeSelectors(bool isWideEnough) {
    if (_isAllDay) {
      // Only show date selectors for all-day events, remove the "All Day" label
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Start date
          ListTile(
            leading: const Icon(Icons.event),
            title: Text(_editorSettings.startDateLabel),
            subtitle:
                Text(DateFormat(_editorSettings.dateFormat).format(_startDate)),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () => _selectDate(context, true),
          ),

          const Divider(),

          // End date
          ListTile(
            leading: const Icon(Icons.event_busy),
            title: Text(_editorSettings.endDateLabel),
            subtitle:
                Text(DateFormat(_editorSettings.dateFormat).format(_endDate)),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () => _selectDate(context, false),
          ),
        ],
      );
    }

    if (isWideEnough) {
      // Wide layout - date and time side by side
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Start date and time
          Row(
            children: [
              Expanded(
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(_editorSettings.startDateLabel),
                  subtitle: Text(DateFormat(_editorSettings.dateFormat)
                      .format(_startDate)),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(_editorSettings.startTimeLabel),
                  subtitle: Text(DateFormat(_editorSettings.timeFormat)
                      .format(_startDate)),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () => _selectTime(context, true),
                ),
              ),
            ],
          ),

          const Divider(),

          // End date and time
          Row(
            children: [
              Expanded(
                child: ListTile(
                  leading: const Icon(Icons.event_busy),
                  title: Text(_editorSettings.endDateLabel),
                  subtitle: Text(
                      DateFormat(_editorSettings.dateFormat).format(_endDate)),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () => _selectDate(context, false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ListTile(
                  leading: const Icon(Icons.access_time_filled),
                  title: Text(_editorSettings.endTimeLabel),
                  subtitle: Text(
                      DateFormat(_editorSettings.timeFormat).format(_endDate)),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () => _selectTime(context, false),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Narrow layout - date and time stacked
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Start date and time
          ListTile(
            leading: const Icon(Icons.event),
            title: Text(_editorSettings.startDateLabel),
            subtitle:
                Text(DateFormat(_editorSettings.dateFormat).format(_startDate)),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () => _selectDate(context, true),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(_editorSettings.startTimeLabel),
            subtitle:
                Text(DateFormat(_editorSettings.timeFormat).format(_startDate)),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () => _selectTime(context, true),
          ),

          const Divider(),

          // End date and time
          ListTile(
            leading: const Icon(Icons.event_busy),
            title: Text(_editorSettings.endDateLabel),
            subtitle:
                Text(DateFormat(_editorSettings.dateFormat).format(_endDate)),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () => _selectDate(context, false),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.access_time_filled),
            title: Text(_editorSettings.endTimeLabel),
            subtitle:
                Text(DateFormat(_editorSettings.timeFormat).format(_endDate)),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () => _selectTime(context, false),
          ),
        ],
      );
    }
  }
}
