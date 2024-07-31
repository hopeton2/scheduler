part of scheduler;

class ViewNavigator extends StatefulWidget {
  final bool isDropdown;
  const ViewNavigator({Key? key, this.isDropdown = true}) : super(key: key);

  @override
  ViewNavigatorState createState() => ViewNavigatorState();
}

class ViewNavigatorState extends State<ViewNavigator> with IntervalConfig {
  final SchedulerController controller = SchedulerService().scheduler.controller;
  final Scheduler scheduler = SchedulerService().scheduler;
  final SchedulerSettings schedulerSettings = SchedulerService().scheduler.schedulerSettings;

  selectView(CalendarViewType viewType) {
    controller.viewType = viewType;
  }

  @override
  initState() {
    selectView(controller.viewType);
    super.initState();
    controller.addListener(() => mounted ? setState(()=>{}) : null);
    ViewNavigationService().addListener(() => mounted ? setState(()=>{}) : null);
  }

  @override
  dispose() {
    controller.removeListener(()=>{});
    ViewNavigationService().removeListener(()=>{});
    super.dispose();
  }

  selectDate() async {
    var selectedDate = await showDatePicker(
      context: context,
      initialDatePickerMode: DatePickerMode.day,
      initialDate: startDate,
      initialEntryMode: DatePickerEntryMode.calendar,
      firstDate: DateTime.now().addYears(-100),
      lastDate: DateTime.now().addYears(100),
      // locale: Locale(scheduler.schedulerSettings.locale)
    );
    if (selectedDate != null) {
      controller.selectDate(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey dateSelectionKey = GlobalKey();

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 0.5, color: scheduler.schedulerSettings.getDividerLineColor(context)),
        ),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: TextButton(
                  onPressed: () => controller.selectToday(),
                  child: const Text(kTodayCaption),),),
          Visibility(
            visible: !SchedulerViewHelper.isSmallDevice(context),
            child: IconButton(
              iconSize: 20.0,
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => controller.gotoPreviousPage(),
            ),
          ),
          Visibility(
            visible: !SchedulerViewHelper.isSmallDevice(context),
            child: IconButton(
              iconSize: 20.0,
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () =>  controller.gotoNextPage(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Text(
                ViewNavigationService().navigationRangeToString(startDate),
                key: dateSelectionKey,),
          ),
          IconButton(
            //iconSize: 20.0,
            icon: const Icon(Icons.arrow_drop_down),
            onPressed: () => selectDate(),
          ),
        ]),
        if (widget.isDropdown)
          PopupNavigationEx(selectView: selectView, showSelection: !SchedulerViewHelper.isSmallDevice(context))
        else
          ButtonNavigation(selectView: selectView),
      ]),
    );
  }
}


