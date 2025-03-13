import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../scheduler.dart';
import '../../services/view_navigation_service.dart';

class ButtonNavigationEx extends StatefulWidget {
  final Function(CalendarViewType viewType) selectView;
  const ButtonNavigationEx({super.key, required this.selectView});

  @override
  _ButtonNavigationExState createState() => _ButtonNavigationExState();
}

class _ButtonNavigationExState extends State<ButtonNavigationEx> {
  late CalendarViewType _selectedViewType;

  @override
  void initState() {
    super.initState();
    _selectedViewType = ViewNavigationService().viewType;
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Scrollbar(
        child: SingleChildScrollView(
          primary: true,
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SegmentedButton<CalendarViewType>(
              segments: kViewTypes.asMap().entries.map((entry) {
                return ButtonSegment<CalendarViewType>(
                  value: entry.value,
                  label: Text(kViewCaptions[entry.key]),
                  // Remove the icon to prevent width changes
                  icon: null,
                );
              }).toList(),
              selected: {_selectedViewType},
              onSelectionChanged: (Set<CalendarViewType> selected) {
                setState(() {
                  _selectedViewType = selected.first;
                  widget.selectView(_selectedViewType);
                });
              },
              showSelectedIcon: false, // This prevents the checkmark from appearing
            ),
          ),
        ),
      ),
    );
  }
}