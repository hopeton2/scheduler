import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scheduler/scheduler.dart';
import 'package:scheduler/services/scheduler_service.dart';
import 'package:scheduler/services/recurrence_service.dart';

class RecurrenceOption {
  final RecurrenceType type;
  final String label;

  const RecurrenceOption(this.type, this.label);
}

class RecurrenceEditor extends StatefulWidget {
  final String? initialRecurrenceRule;
  final DateTime baseDate;
  final Function(String?) onRecurrenceChanged;
  final bool initiallyExpanded;

  const RecurrenceEditor({
    Key? key,
    required this.baseDate,
    required this.onRecurrenceChanged,
    this.initialRecurrenceRule,
    this.initiallyExpanded = false,
  }) : super(key: key);

  @override
  State<RecurrenceEditor> createState() => _RecurrenceEditorState();
}

class _RecurrenceEditorState extends State<RecurrenceEditor> {
  // Recurrence variables
  RecurrenceType _recurrenceType = RecurrenceType.none;
  int _recurrenceInterval = 1;
  DateTime? _recurrenceEndDate;
  int? _recurrenceCount;
  bool _hasRecurrenceEnd = false;
  List<int>? _weeklyDays; // 1=Monday, 7=Sunday
  int? _monthlyDay;
  bool _showRecurrenceOptions = false;

  late final List<RecurrenceOption> _recurrenceOptions;

  @override
  void initState() {
    super.initState();

    // Initialize from base date
    _weeklyDays = [widget.baseDate.weekday % 7 + 1];
    _monthlyDay = widget.baseDate.day;
    _showRecurrenceOptions = widget.initiallyExpanded;

    // Setup recurrence options using settings
    final settings = SchedulerService().scheduler.recurrenceSettings;
    _recurrenceOptions = [
      RecurrenceOption(RecurrenceType.none, settings.noRecurrenceLabel),
      RecurrenceOption(RecurrenceType.daily, settings.dailyLabel),
      RecurrenceOption(RecurrenceType.weekly, settings.weeklyLabel),
      RecurrenceOption(RecurrenceType.monthly, settings.monthlyLabel),
      RecurrenceOption(RecurrenceType.yearly, settings.yearlyLabel),
    ];

    // Initialize recurrence options from rule if provided
    if (widget.initialRecurrenceRule != null &&
        widget.initialRecurrenceRule!.isNotEmpty) {
      _initializeRecurrenceFromRule(widget.initialRecurrenceRule!);
      _showRecurrenceOptions = true;
    }
  }

  // Parse recurrence rule and set initial values
  void _initializeRecurrenceFromRule(String recurrenceRule) {
    // Use RecurrenceService to parse the rule
    final result =
        RecurrenceService.instance.parseRecurrenceRule(recurrenceRule);

    _recurrenceType = result.type;
    _recurrenceInterval = result.interval;
    _recurrenceCount = result.count;
    _recurrenceEndDate = result.until;
    _weeklyDays = result.weekDays ?? [widget.baseDate.weekday % 7 + 1];
    _monthlyDay = result.monthDay ?? widget.baseDate.day;
    _hasRecurrenceEnd = result.hasEnd;
  }

  // Generate recurrence rule string
  String? _buildRecurrenceRule() {
    if (_recurrenceType == RecurrenceType.none) {
      return null;
    }

    // Use RecurrenceService to build the rule
    return RecurrenceService.instance.buildRecurrenceRule(
      type: _recurrenceType,
      interval: _recurrenceInterval,
      count: _hasRecurrenceEnd ? _recurrenceCount : null,
      until: _hasRecurrenceEnd && _recurrenceCount == null
          ? _recurrenceEndDate
          : null,
      weekDays: _weeklyDays,
      monthDay: _monthlyDay,
    );
  }

  String _getIntervalLabel() {
    final settings = SchedulerService().scheduler.recurrenceSettings;
    switch (_recurrenceType) {
      case RecurrenceType.daily:
        return _recurrenceInterval == 1
            ? settings.dayLabel
            : settings.daysLabel;
      case RecurrenceType.weekly:
        return _recurrenceInterval == 1
            ? settings.weekLabel
            : settings.weeksLabel;
      case RecurrenceType.monthly:
        return _recurrenceInterval == 1
            ? settings.monthLabel
            : settings.monthsLabel;
      case RecurrenceType.yearly:
        return _recurrenceInterval == 1
            ? settings.yearLabel
            : settings.yearsLabel;
      default:
        return '';
    }
  }

  Widget _buildDayToggle(String label, int day) {
    final isSelected = _weeklyDays?.contains(day) ?? false;
    return InkWell(
      onTap: () {
        setState(() {
          if (_weeklyDays == null) {
            _weeklyDays = [day];
          } else if (isSelected && _weeklyDays!.length > 1) {
            _weeklyDays!.remove(day);
          } else if (!isSelected) {
            _weeklyDays!.add(day);
            _weeklyDays!.sort();
          }
        });
        _updateRecurrenceRule();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectRecurrenceEndDate(BuildContext context) async {
    final settings = SchedulerService().scheduler.recurrenceSettings;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _recurrenceEndDate ?? widget.baseDate.add(const Duration(days: 30)),
      firstDate: widget.baseDate,
      lastDate: widget.baseDate.add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        _recurrenceEndDate = picked;
      });
      _updateRecurrenceRule();
    }
  }

  void _updateRecurrenceRule() {
    final recurrenceRule = _buildRecurrenceRule();
    widget.onRecurrenceChanged(recurrenceRule);
  }

  @override
  Widget build(BuildContext context) {
    final settings = SchedulerService().scheduler.recurrenceSettings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recurrence toggle row
        Row(
          children: [
            const Icon(Icons.repeat, size: 20),
            const SizedBox(width: 8),
            Text(
              settings.recurrenceLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Switch(
              value: _showRecurrenceOptions,
              onChanged: (value) {
                setState(() {
                  _showRecurrenceOptions = value;
                  if (!value) {
                    _recurrenceType = RecurrenceType.none;
                  } else if (_recurrenceType == RecurrenceType.none) {
                    _recurrenceType = RecurrenceType.daily;
                  }
                });
                _updateRecurrenceRule();
              },
            ),
          ],
        ),

        if (_showRecurrenceOptions) ...[
          const SizedBox(height: 16),

          // Recurrence type dropdown
          DropdownButtonFormField<RecurrenceType>(
            decoration: InputDecoration(
              labelText: settings.repeatLabel,
              border: const OutlineInputBorder(),
            ),
            value: _recurrenceType,
            items: _recurrenceOptions.map((option) {
              return DropdownMenuItem(
                value: option.type,
                child: Text(option.label),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _recurrenceType = value!;
              });
              _updateRecurrenceRule();
            },
          ),

          const SizedBox(height: 16),

          // Recurrence interval
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: settings.everyLabel,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: _recurrenceInterval.toString(),
                  onChanged: (value) {
                    final interval = int.tryParse(value);
                    if (interval != null && interval > 0) {
                      _recurrenceInterval = interval;
                      _updateRecurrenceRule();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Text(_getIntervalLabel()),
              ),
            ],
          ),

          // Weekly recurrence days
          if (_recurrenceType == RecurrenceType.weekly) ...[
            const SizedBox(height: 16),
            Text(settings.repeatOnLabel),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(7, (index) {
                int day = index + 1;
                String label = settings.weekdayShortLabels[index];
                return _buildDayToggle(label, day);
              }),
            ),
          ],

          // Monthly recurrence day
          if (_recurrenceType == RecurrenceType.monthly) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text(settings.dayOfMonthLabel),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  value: _monthlyDay,
                  items: List.generate(31, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text((index + 1).toString()),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _monthlyDay = value;
                    });
                    _updateRecurrenceRule();
                  },
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Recurrence end options
          Row(
            children: [
              Text(settings.endsLabel),
              const SizedBox(width: 16),
              Radio<bool>(
                value: false,
                groupValue: _hasRecurrenceEnd,
                onChanged: (value) {
                  setState(() {
                    _hasRecurrenceEnd = value!;
                  });
                  _updateRecurrenceRule();
                },
              ),
              Text(settings.neverLabel),
              const SizedBox(width: 16),
              Radio<bool>(
                value: true,
                groupValue: _hasRecurrenceEnd,
                onChanged: (value) {
                  setState(() {
                    _hasRecurrenceEnd = value!;
                    if (_recurrenceEndDate == null &&
                        _recurrenceCount == null) {
                      _recurrenceEndDate =
                          widget.baseDate.add(const Duration(days: 30));
                    }
                  });
                  _updateRecurrenceRule();
                },
              ),
              Text(settings.endAfterOnLabel),
            ],
          ),

          if (_hasRecurrenceEnd) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _recurrenceCount != null,
                  onChanged: (value) {
                    setState(() {
                      if (value!) {
                        _recurrenceCount = _recurrenceCount ?? 10;
                        _recurrenceEndDate = null;
                      }
                    });
                    _updateRecurrenceRule();
                  },
                ),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: settings.occurrencesLabel,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _recurrenceCount?.toString() ?? '10',
                    enabled: _recurrenceCount != null,
                    onChanged: (value) {
                      final count = int.tryParse(value);
                      if (count != null && count > 0) {
                        setState(() {
                          _recurrenceCount = count;
                          _recurrenceEndDate = null;
                        });
                        _updateRecurrenceRule();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Radio<bool>(
                  value: false,
                  groupValue: _recurrenceCount != null,
                  onChanged: (value) {
                    setState(() {
                      if (!value!) {
                        _recurrenceCount = null;
                        _recurrenceEndDate = _recurrenceEndDate ??
                            widget.baseDate.add(const Duration(days: 30));
                      }
                    });
                    _updateRecurrenceRule();
                  },
                ),
                Expanded(
                  child: ListTile(
                    title: Text(settings.endDateLabel),
                    subtitle: Text(_recurrenceEndDate != null
                        ? DateFormat('EEE, MMM d, yyyy')
                            .format(_recurrenceEndDate!)
                        : settings.selectDateLabel),
                    onTap: _recurrenceCount == null
                        ? () => _selectRecurrenceEndDate(context)
                        : null,
                    enabled: _recurrenceCount == null,
                  ),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}
