part of scheduler;

class WeekView extends StatefulWidget {
  final bool isWorkWeek;
  const WeekView({Key? key, DateTime? date, this.isWorkWeek = false }) : super(key: key);


  get days => isWorkWeek ? 5 : 7;

  @override
  _WeekViewState createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {

  @override
  Widget build(BuildContext context) {
    return DayView(dayCount: widget.days);
  }
}
