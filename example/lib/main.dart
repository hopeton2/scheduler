// ignore: depend_on_referenced_packages
import 'package:dart_date/dart_date.dart';
import 'package:flutter/material.dart';

import 'package:scheduler/extensions/color_extensions.dart';
import 'package:scheduler/scheduler.dart';

import 'app_month_view_theme.dart';

Future<void> main() async {
  //debugRepaintRainbowEnabled = true;
  runApp(
      const MyApp()
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Iterable<ThemeExtension<dynamic>> getThemeExtensions() {
    //return [AppMonthViewTheme()];
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // locale: DevicePreview.locale(context),
        // builder: DevicePreview.appBuilder,
        theme: ThemeData.dark(useMaterial3: true).copyWith(extensions: getThemeExtensions()),
        //darkTheme: ThemeData.dark(),

      debugShowCheckedModeBanner: false,
      title: 'Jazmine Scheduler Demo',

       // home: const SafeArea(child: Syncfusion())
        // home: SafeArea(child: jzDayView())
        // home: SafeArea(child: jzWeekView())
        //  home: SafeArea(child: Scheduler(view: TimelineView(pages: 5, calendarType: CalendarType.month, intervalMinute: IntervalMinute.min15)))
        home: SafeArea(child: JzScheduler(dataSource: getDataSource(), viewType: CalendarViewType.week,  initialDate: DateTime.now(),
             schedulerSettings: const SchedulerSettings(
 //           locale: 'Ja_Jp'
/*            headerBackgroundColor: Colors.white,
            headerFontColor: Colors.black,
            timebarFontColor: Colors.black,
              timebarBackgroundColor: Colors.white,
              dividerLineColor: Colors.black,
              locale: 'ja_JP'*/
          ),
          dayViewSettings: const DayViewSettings(
            intervalMinute: IntervalMinute.min30,
            headerStyleName: 'dayStyle3',
            showMinutes: true,
          ),
          monthViewSettings: const MonthViewSettings(
            showWeekNumber: true,
            headerDayNameFormat: "EEEE"
        ), ))
    );
  }

  SchedulerDataSource getDataSource() {
    SchedulerDataSource result = SchedulerDataSource();
    int year = DateTime.now().year;
    int month = DateTime.now().month;
    int lastMonth = month -1;

    DateTime today = DateTime.now().startOfDay.addHours(2);
    result.addAllDayAppointment(today, "This is all day", color: ColorsExt.random);
    result.addAllDayAppointment(today, "This is another all day - 3 days", color: ColorsExt.random, days: 3);
    

    result.addAppointment(today.addMonths(-1), const Duration(minutes: 120), "last month", color: Colors. red);

    result.addAppointment(today, const Duration(days: 5), "Morning meeting with India", color: ColorsExt.random);

    result.addAppointment(today.addDays(1), const Duration(minutes: 220), "Breakfast", color: ColorsExt.random);
    result.addAppointment(today.addDays(2), const Duration(minutes: 220), "Breakfast 2", color: ColorsExt.random);
    result.addAppointment(today.addHours(4), const Duration(minutes: 220), "Workout", color: ColorsExt.random);
    result.addAppointment(today, const Duration(minutes: 80), "test red", color: ColorsExt.random);
    result.addAppointment(today, const Duration(minutes: 180), "test blue", color: ColorsExt.random);
    result.addAppointment(today, const Duration(days: 2), "Multiple Days", color: ColorsExt.random);

    //return result;
    result.addAllDayAppointment(today, "This is all day", color: ColorsExt.random);
    result.addAllDayAppointment(today, "This is another all day", color: ColorsExt.random, days: 3);
    result.addAppointment(today, const Duration(minutes: 120), "Morning meeting with India", color: ColorsExt.random);
    result.addAppointment(today.addDays(1), const Duration(minutes: 220), "Breakfast", color: ColorsExt.random);
    result.addAppointment(today.addDays(2), const Duration(minutes: 220), "Breakfast", color: ColorsExt.random);
    result.addAppointment(today.addHours(4), const Duration(minutes: 220), "Workout", color: ColorsExt.random);
    result.addAppointment(today, const Duration(minutes: 80), "test red", color: ColorsExt.random);
    result.addAppointment(today, const Duration(minutes: 180), "test blue", color: ColorsExt.random);

    result.addAppointment(today, const Duration(minutes: 120), "Morning meeting with India", color: ColorsExt.random);
    result.addAppointment(today.addDays(1), const Duration(minutes: 220), "Breakfast", color: ColorsExt.random);
    result.addAppointment(today.addDays(2), const Duration(minutes: 220), "Breakfast", color: ColorsExt.random);
    result.addAppointment(today.addHours(4), const Duration(minutes: 220), "Workout", color: ColorsExt.random);
    result.addAppointment(today, const Duration(minutes: 80), "test red", color: ColorsExt.random);
    result.addAppointment(today, const Duration(minutes: 180), "test blue", color: ColorsExt.random);

    result.addAppointment(DateTime(year,month,14,3,0), const Duration(minutes: 120), "test 1", color: ColorsExt.random);
    result.addAppointment(DateTime(year,month,14,2,45), const Duration(minutes: 180), "test 5", color: ColorsExt.random);
    result.addAppointment(DateTime(year,month,14,5,15), const Duration(minutes: 80), "test 10", color: ColorsExt.random);

   Color color = Colors.green;
    result.addAppointment(DateTime(year,lastMonth,22,8,45), const Duration(minutes: 120), "g1", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,6,00), const Duration(minutes: 250), "g2", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,8,30), const Duration(minutes: 120), "g3", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,9,30), const Duration(minutes: 120), "g4", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,9,17), const Duration(minutes: 140), "g5", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,10,00), const Duration(minutes: 120), "g6", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,8,00), const Duration(minutes: 75), "g7", color: color);

    color = Colors.blue;
    result.addAppointment(DateTime(year,lastMonth,22,8,45), const Duration(minutes: 120), "b1", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,6,00), const Duration(minutes: 250), "b2", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,8,30), const Duration(minutes: 120), "b3", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,9,30), const Duration(minutes: 120), "b4", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,9,17), const Duration(minutes: 140), "b5", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,10,00), const Duration(minutes: 120), "b6", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,8,00), const Duration(minutes: 75), "b7", color: color);

    color = Colors.blueGrey;
    result.addAppointment(DateTime(year,lastMonth,22,8,30), const Duration(minutes: 120), "l1", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,9,30), const Duration(minutes: 120), "l2", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,10,00), const Duration(minutes: 140), "l3", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,10,00), const Duration(minutes: 120),"l5", color: color);

    color = Colors.purple;
    result.addAppointment(DateTime(year,lastMonth,22,8,30), const Duration(minutes: 120), "p1", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,9,15), const Duration(minutes: 120), "p2", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,9,15), const Duration(minutes: 60), "p3", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,9,00), const Duration(minutes: 120), "p4", color: color);
    result.addAppointment(DateTime(year,lastMonth,22,8,00), const Duration(minutes: 75), "p5", color: color);

    color = Colors.orange;
    result.addAppointment(DateTime(year,lastMonth,24,8,30), const Duration(minutes: 120), "1", color: color);
    result.addAppointment(DateTime(year,lastMonth,24,9,30), const Duration(minutes: 120), "2", color: color);
    result.addAppointment(DateTime(year,lastMonth,24,10,00), const Duration(minutes: 140), "3", color: color);
    result.addAppointment(DateTime(year,lastMonth,24,10,00), const Duration(minutes: 120), "4", color: color);
    result.addAppointment(DateTime(year,lastMonth,24,8,00), const Duration(minutes: 75), "5", color: color);

    color = Colors.red;
    result.addAppointment(DateTime(year,lastMonth,26,8,30), const Duration(minutes: 320), "1R", color: color);

    return result;
  }



/*  Widget sfCalendar() {
    return  SfCalendar(view: CalendarView.workWeek, allowViewNavigation: true, timeSlotViewSettings: const TimeSlotViewSettings(
        startHour: 0,
        endHour: 24,
        nonWorkingDays: <int>[
          DateTime.saturday,
          DateTime.sunday,
        ],
        timeInterval: Duration(minutes: 22),
        timeIntervalHeight: 40,
        timeFormat: 'h:mm',
        dateFormat: 'd',
        dayFormat: 'EE',
        timeRulerSize: 60),
    );
  }*/
}

