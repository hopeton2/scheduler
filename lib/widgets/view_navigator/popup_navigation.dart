import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../scheduler.dart';
import '../../services/view_navigation_service.dart';

class PopupNavigation extends StatefulWidget {
  final Function(CalendarViewType viewType) selectView;
  const PopupNavigation({super.key, required this.selectView});

  @override
  State<PopupNavigation> createState() => _PopupNavigationState();
}

class _PopupNavigationState extends State<PopupNavigation> {
  String selectedDropdown = '';

  @override
  initState() {
    selectedDropdown =
        kViewCaptions[kViewTypes.indexOf(ViewNavigationService().viewType)];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
          style:
              Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 12),
          focusColor: Colors.transparent,
          isDense: false,
          value: selectedDropdown,
          items: kViewCaptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? value) {
            selectedDropdown = value!;
            var index = kViewCaptions.indexOf(value);
            widget.selectView(kViewTypes[index]);
            setState(()=>{});
          },),
    );
  }
}
