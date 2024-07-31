import 'package:flutter/material.dart';

import '../../interval_config.dart';
import '../../scheduler.dart';
import '../../scheduler_scroll_behavior.dart';
import '../../services/services.dart';

class VirtualPageView extends StatefulWidget {
  final Function(int virtualIndex)? afterScroll;
  final Function(int virtualIndex)? beforeScroll;
  final Function(int virtualIndex, int index)? onPageChanged;
  final int virtualCount;
  final Widget? Function(BuildContext context, DateTime pageDate, int index)
      itemBuilder;
  final DateIncrementer? pageDateIncrementer;
  final DateTime initialDate;
  const VirtualPageView({
    Key? key,
    this.beforeScroll,
    this.afterScroll,
    this.onPageChanged,
    this.virtualCount = 1000000,
    this.pageDateIncrementer,
    required this.initialDate,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  _VirtualPageViewState createState() => _VirtualPageViewState();
}

class _VirtualPageViewState extends State<VirtualPageView> with IntervalConfig {
  late PageController _pageController;
  int initialPage = 0;
  int virtualInitialPage = 0;
  int currentPage = 0;
  int pageOffset = 0;

  @override
  void initState() {
    initialPage = (widget.virtualCount / 2).floor();
    virtualInitialPage = initialPage;
    currentPage = initialPage;

    _pageController = PageController(initialPage: initialPage);
    _pageController.addListener(() {
      schedulerService.scheduler.controller.canSelectAndJumpToDayView =
          !_pageController.position.isScrollingNotifier.value;
    });
    subscribeToNavServiceScrolling();
    super.initState();
  }

  subscribeToNavServiceScrolling() {
    Duration duration = const Duration(milliseconds: 500);
    Curve curve = Curves.decelerate;
    viewNavigationService.scrollNextPageNotify.addListener(() => {
          if (_pageController.positions.isNotEmpty)
            _pageController.nextPage(duration: duration, curve: curve),
        });
    viewNavigationService.scrollPreviousPageNotify.addListener(() => {
          if (_pageController.positions.isNotEmpty)
            _pageController.previousPage(duration: duration, curve: curve),
        });
    _pageController.addListener(() {
      if (_pageController.positions.isNotEmpty) {
        if (_pageController.page == _pageController.page!.toInt()) {
          int newPage = _pageController.page!.toInt();
          if (newPage == currentPage) {
            DateTime date = calcPageDate(currentPage);
            viewService.scrollSnapback.value = date;
            debugPrint("page not changed!");
            setState(() {
              
            });
          } else {
            currentPage = newPage;
          }
        }
      }
    });
  }

  _handlePageChange(int index) {
        int virtualPageIndex = index - virtualInitialPage;
        viewNavigationService.viewPageChanged(virtualPageIndex);
        widget.onPageChanged?.call(virtualPageIndex, index);
        DateTime pageDate = calcPageDate(index);
        schedulerService.scheduler.controller.setNavDate(pageDate);
        initialPage = index;
  }

  @override
  void dispose() {
    viewNavigationService.scrollPreviousPageNotify.removeListener(() => {});
    viewNavigationService.scrollNextPageNotify.removeListener(() => {});
    _pageController.dispose();
    super.dispose();
  }

  DateTime calcPageDate(int index) {
    int virtualPageIndex = index - initialPage;
    DateTime date = startDate;
    DateTime result = widget.pageDateIncrementer != null
        ? widget.pageDateIncrementer!(date, virtualPageIndex)
        : incrementPageDate(date, multiplier: virtualPageIndex);

    debugPrint(index.toString());
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      allowImplicitScrolling: false,
      scrollBehavior: SchedulerScrollBehavior(),
      pageSnapping: true,
      scrollDirection: Axis.horizontal,
      itemCount: widget.virtualCount,
      controller: _pageController,
      onPageChanged: (index) => _handlePageChange(index),
      itemBuilder: (context, index) {
        int virtualPageIndex = index - initialPage;
        widget.beforeScroll?.call(virtualPageIndex);
        DateTime pageDate = calcPageDate(index);
        Widget? item = widget.itemBuilder(context, pageDate, virtualPageIndex);
        widget.afterScroll?.call(virtualPageIndex);

        return item;
      },
    );
  }
}
