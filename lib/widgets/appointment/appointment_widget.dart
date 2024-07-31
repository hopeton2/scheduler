part of scheduler;

typedef AppointmentViewBuilder = Widget Function({double opacity, bool dragging});

class AppointmentWidget extends StatefulWidget {
  final AppointmentItem appointmentItem;
  final TextStyle? textStyle;
  final Decoration? decoration;
  final AppointmentRenderService appointmentRenderService;
  final FlowOrientation orientation;
  final int index;
  const AppointmentWidget(
    this.index,
    this.appointmentItem,
    this.appointmentRenderService,
    this.orientation, {
    Key? key,
    this.textStyle,
    this.decoration,
  }) : super(key: key);

  @override
  State<AppointmentWidget> createState() => _AppointmentWidgetState();
}

class _AppointmentWidgetState extends State<AppointmentWidget> with TickerProviderStateMixin {
  Timer? longPressTimer;
  SlotSelector? slotSelector;
  final AppointmentSettings settings = SchedulerService().scheduler.appointmentSettings;
  final Scheduler scheduler = SchedulerService().scheduler;
  final ValueNotifier<bool> hoverNotifier = ValueNotifier<bool>(false);
  final AppointmentService appointmentService = AppointmentService.instance;
  late final StreamSubscription? _appointmentSelectedSubscription;

  late final AnimationController _animationController = AnimationController(
    duration: settings.animationDuration,
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeIn,
  );

  get isLast => widget.appointmentItem.isLast;
  get isFirst => widget.appointmentItem.isFirst;


  bool _isHovered = false;
  Appointment get appointment {
    return widget.appointmentItem.appointment;
  }

  bool get isHovered => _isHovered && !AppointmentDragService().isDragging;
  set isHovered(bool value) {
    if (value != _isHovered) {
      _isHovered = value;
      hoverNotifier.value = value;
    }
  }

  get isSelected =>
      appointmentService.selectedAppointment ==
      widget.appointmentItem.appointment;

  @override
  initState() {
    super.initState();
    _animationController.forward();
    _appointmentSelectedSubscription =
        appointmentService.$appointmentSelected.listen((appointment) {
      //if (appointment != widget.appointmentItem.appointment) {
        setState(() {});
      //}
    });
  }

  @override
  dispose() {
    _animationController.dispose();
    _appointmentSelectedSubscription?.cancel();
    cancelLongPressTimer();
    super.dispose();
  }

  cancelLongPressTimer() {
    longPressTimer?.cancel();
    longPressTimer = null;
  }

  
  BorderRadius borderRadius(Radius? cornerRadius) {
    Radius borderRadius = cornerRadius ?? const Radius.circular(4);
    BorderRadiusGeometry result = BorderRadius.all(borderRadius);
    if (!isFirst) {
      if (widget.orientation == FlowOrientation.vertical) {
        result = result.subtract(BorderRadius.only(topLeft: borderRadius, topRight: borderRadius));
      } else {
        result = result.subtract(BorderRadius.only(topLeft: borderRadius, bottomLeft: borderRadius));
      }
    }
    if (!isLast) {
      if (widget.orientation == FlowOrientation.vertical) {
        result = result.subtract(BorderRadius.only(bottomLeft: borderRadius, bottomRight: borderRadius));
      } else {
        result = result.subtract(BorderRadius.only(topRight: borderRadius, bottomRight: borderRadius));
      }
    }
    return result as BorderRadius;
  }

  BorderSide openBorder(bool isDragging) {
    double width = 1;
    Color color = appointment.color.darken(.25);
    if (!isDragging) {
      if (isSelected) {
        width = 1.5;
        color = settings.getSelectionBorderColor(context);
      } else if (isHovered) {
        color = settings.getHoverBorderColor(context);
      }
    }

    return BorderSide(width: width, color: color);
  }

  Border border(bool isDragging){
    double width = 1;
    Color color = appointment.color.darken(.25);
    if(!isDragging){
      if (isSelected) {
        width = 1.5;
        color = settings.getSelectionBorderColor(context);
      } else if (isHovered) {
        color = settings.getHoverBorderColor(context);
      }
    }
    return Border.all(width: width, color: color);
  }

 selectAppointment() {
     slotSelector?.clearSelection();
     AppointmentService.instance.selectAppointment(appointment);
  }

  @override
  Widget build(BuildContext context) {
    const minResponsiveHeight = 50;
    final rect = widget.appointmentItem.geometry.rect;
    slotSelector = scheduler.slotSelector;
    Color color = widget.appointmentItem.appointment.color;
    double height = rect.height;
    double width = rect.width == double.infinity ? 0 : max(0, rect.width);
    Color textColor = settings.fontColorLuminanceAware ?
    color.computeLuminance() > 0.5 ? Colors.black : Colors.white : settings.fontColor;


    Widget appointmentViewBody(double opacity, bool dragging) {
      return Visibility(
        visible: height > 0,
        child: Container(
            padding: const EdgeInsets.only(left: 4, top: 1, bottom: 1, right: 4),
            decoration: widget.decoration ??
                BoxDecoration(
                  color: color.withOpacity(opacity),
                  border: border(dragging),
                  borderRadius: borderRadius(settings.cornerRadius),
                ),
            height: max(0, height),
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.appointmentItem.appointment.subject,
                    style: widget.textStyle ??
                        TextStyle(
                            color: textColor,
                            fontSize: height >= minResponsiveHeight ? 12.0 : min(12, height * .5),
                            overflow: TextOverflow.ellipsis,),),
                Visibility(
                  visible: height > minResponsiveHeight,
                  child: ClipRect(
                    child: Text(
                        '${DateFormat('h:mm a').format(widget.appointmentItem.appointment.startDate)} - ${DateFormat('h:mm a')
                                .format(widget.appointmentItem.appointment.endDate)}',
                        style: widget.textStyle ??
                            TextStyle(
                                color: textColor,
                                fontSize: 12.0,
                                overflow: TextOverflow.ellipsis,),),
                  ),
                ),
              ],
            ),),
      );
    }

    Widget appointmentView({double opacity = 1, bool dragging = false}) {
      return Tooltip(
        message: appointment.shortSummary,
        child: Padding(
          padding: const EdgeInsets.only(left: 0.5),
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) {
              isHovered = false;
              if (SchedulerViewHelper.isMobileLayout(context)) {
                longPressTimer = Timer(settings.selectionDelay, () {
                  cancelLongPressTimer();
                  if (settings.hapticFeedbackOnLongPressSelection) {
                      HapticFeedback.selectionClick();
                  }
                  selectAppointment();
                });
              }
            },
            onPointerUp: (event) {
              cancelLongPressTimer();
              if (!SchedulerViewHelper.isMobileLayout(context)) {
                selectAppointment();
              }
            },
            onPointerMove: (event) {
              if (event.down && event.delta.distanceSquared > 2) {
                cancelLongPressTimer();
              }
            },
            onPointerSignal: (pointerSignal) {
              //--handle vertical wheel scrolling
              if (pointerSignal is PointerScrollEvent && widget.orientation == FlowOrientation.vertical) {
                SchedulerService.instance.scrollScheduler(pointerSignal.scrollDelta.dy);
              }
            },
            child: MouseRegion(
              cursor: DraggableCursor(),
              opaque: !SchedulerViewHelper.isMobileLayout(context),
              onEnter: (event) {
                if (event.kind == PointerDeviceKind.mouse) {
                  isHovered = true;
                }
              },
              onExit: (event) {
                isHovered = false;
              },
              child: ValueListenableBuilder(
                  valueListenable: hoverNotifier,
                  builder: (BuildContext context, bool hovered, Widget? child) =>
                      AppointmentResizer(
                          hovered: hovered,
                          orientation: widget.orientation,
                          appointmentItem: widget.appointmentItem,
                          appointmentWidget: widget,
                          child: appointmentViewBody(opacity, dragging),
                      ),
              ),
            ),
          ),
        ),
      );
    }

    return ValueListenableBuilder(
        valueListenable: scheduler.schedulerScrollPosNotify,
        builder: (BuildContext context, Offset scrollOffset, Widget? child) {
          widget.appointmentRenderService.scrollAppointment(widget.appointmentItem, Scheduler.currentScrollPos);

          return Positioned(
            top: widget.appointmentItem.rect.top,
            left: widget.appointmentItem.rect.left,
            child: SchedulerViewHelper.isMobileLayout(context)
                ? appointmentView()
                : AppointmentDragger(
                    orientation: widget.orientation,
                    viewBuilder: appointmentView,
                    appointmentRenderService: widget.appointmentRenderService,
                    appointmentItem: widget.appointmentItem,
                    child: FadeTransition(
                        opacity: _animation,
                        child: appointmentView(),),
            ),
          );
        },);
  }
}

