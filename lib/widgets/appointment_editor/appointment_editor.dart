import 'package:flutter/material.dart';
import 'package:scheduler/common/scheduler_view_helper.dart';
import 'package:scheduler/scheduler.dart';
import 'package:intl/intl.dart';

import '../../services/scheduler_service.dart';

class AppointmentEditor extends StatefulWidget {
  final Appointment? appointment;
  
  const AppointmentEditor({
    Key? key, 
    this.appointment,
  }) : super(key: key);

  @override
  State<AppointmentEditor> createState() => _AppointmentEditorState();
}

class _AppointmentEditorState extends State<AppointmentEditor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _subjectController;
  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _isAllDay = false;
  Color _color = Colors.grey;

  @override
  void initState() {
    super.initState();
    final selectedDate = SchedulerService.instance.scheduler.controller.selectedDate;
    
    _subjectController = TextEditingController(text: widget.appointment?.subject ?? '');
    if (widget.appointment != null) {
      _startDate = widget.appointment!.startDate;
      _endDate = widget.appointment!.endDate;
      _isAllDay = widget.appointment!.isAllDay;
      _color = widget.appointment!.color;
    } else {
      // For new appointments, use the selected date
      _startDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        DateTime.now().hour,
        0,
      );
      _endDate = _startDate.add(const Duration(hours: 1));
      _isAllDay = false;
      _color = Colors.grey;
    }
    _startTime = TimeOfDay.fromDateTime(_startDate);
    _endTime = TimeOfDay.fromDateTime(_endDate);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = SchedulerViewHelper.isMobileLayout(context);
    
    return isMobile ? _buildMobileEditor(context) : _buildDesktopEditor(context);
  }

  Widget _buildDesktopEditor(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileEditor(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveAppointment,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.appointment == null ? 'New Event' : 'Edit Event',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _saveAppointment,
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _subjectController,
            decoration: const InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a subject';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateTimePicker(
                  'Start',
                  _startDate,
                  _startTime,
                  (date) => setState(() => _startDate = date),
                  (time) => setState(() => _startTime = time),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateTimePicker(
                  'End',
                  _endDate,
                  _endTime,
                  (date) => setState(() => _endDate = date),
                  (time) => setState(() => _endTime = time),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('All day'),
            value: _isAllDay,
            onChanged: (value) => setState(() => _isAllDay = value),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Color'),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
              ),
            ),
            onTap: _showColorPicker,
          ),
        ],
      ),
    );
  }

  void _showColorPicker() {
    // Implement color picker dialog here
    // For now, just cycle through some basic colors
    setState(() {
      final colors = [
        const Color(0xFF9E9E9E), // Colors.grey
        const Color(0xFF2196F3), // Colors.blue
        const Color(0xFF4CAF50), // Colors.green
        const Color(0xFFF44336), // Colors.red
        const Color(0xFFFF9800), // Colors.orange
        const Color(0xFF9C27B0), // Colors.purple
      ];
      final currentIndex = colors.indexOf(_color);
      _color = colors[(currentIndex + 1) % colors.length];
    });
  }

  Widget _buildDateTimePicker(
    String label,
    DateTime date,
    TimeOfDay time,
    Function(DateTime) onDateChanged,
    Function(TimeOfDay) onTimeChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    onDateChanged(picked);
                  }
                },
                child: Text(DateFormat('MMM dd, yyyy').format(date)),
              ),
            ),
            if (!_isAllDay) ...[
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: time,
                    );
                    if (picked != null) {
                      onTimeChanged(picked);
                    }
                  },
                  child: Text(time.format(context)),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _saveAppointment() {
    if (_formKey.currentState!.validate()) {
      final startDateTime = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _isAllDay ? 0 : _startTime.hour,
        _isAllDay ? 0 : _startTime.minute,
      );

      final endDateTime = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _isAllDay ? 23 : _endTime.hour,
        _isAllDay ? 59 : _endTime.minute,
      );

      final scheduler = SchedulerService.instance.scheduler;
      
      if (widget.appointment != null) {
        // Update existing appointment
        scheduler.dataSource?.rescheduleAppointment(
          widget.appointment!,
          startDateTime,
          endDateTime,
          _isAllDay,
        );
        widget.appointment!.subject = _subjectController.text;
        widget.appointment!.color = _color;
        scheduler.dataSource?.updateListeners();
      } else {
        // Create new appointment
        if (_isAllDay) {
          final days = endDateTime.difference(startDateTime).inDays + 1;
          scheduler.dataSource?.addAllDayAppointment(
            startDateTime,
            _subjectController.text,
            color: _color,
            days: days,
          );
        } else {
          final duration = endDateTime.difference(startDateTime);
          scheduler.dataSource?.addAppointment(
            startDateTime,
            duration,
            _subjectController.text,
            color: _color,
          );
        }
      }

      Navigator.of(context).pop();
    }
  }
}
