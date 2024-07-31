import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../scheduler.dart';
import '../../services/services.dart';

class PopupNavigationEx extends StatefulWidget {
  final Function(CalendarViewType viewType) selectView;
  final bool showSelection;
  const PopupNavigationEx({Key? key, required this.selectView, this.showSelection = true}) : super(key: key);

  @override
  _PopupNavigationExState createState() => _PopupNavigationExState();
}

class _PopupNavigationExState extends State<PopupNavigationEx> {


  get selectionText => kViewCaptions[(kViewTypes.indexOf(viewNavigationService.viewType))];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<CalendarViewType>(
      tooltip: kViewSelectionCaption,
      initialValue: viewNavigationService.viewType,
      onSelected: (CalendarViewType viewType) {
        //setState((){
          widget.selectView(viewType);
       // });
      },
      itemBuilder: (BuildContext context) => kViewTypes.map((viewType) {
        return PopupMenuItem(
          value: viewType,
          child: Text(kViewCaptions[(kViewTypes.indexOf(viewType))]),
        );
      }).toList(),
      child: DropdownSelector(selectionText, !widget.showSelection),
    );
  }
}

class DropdownSelector extends StatelessWidget{
  final String selection;
  final bool isCompact;
  const DropdownSelector(this.selection, this.isCompact, {super.key});

  @override
  Widget build(BuildContext context) {
     return isCompact
         ? const Icon(Icons.more_vert)
         : Row(children: [Text(selection), const Icon(Icons.arrow_drop_down) ]);
  }
}