part of scheduler;

class AppointmentSettings {
  final Color? hoverBorderColor;
  final Color defaultColor;
  final Color fontColor;
  final bool fontColorLuminanceAware;
  final TextStyle? textStyle;
  final double spaceBetween;
  final Radius? cornerRadius;
  final Builder? builder;
  final Color? selectionBorderColor;
  final Duration dragDelay;
  final Duration selectionDelay;
  final Duration animationDuration;
  final bool hapticFeedbackOnLongPressSelection;
  final Duration defaultDuration;

  const AppointmentSettings({
    this.defaultColor = Colors.grey,
    this.fontColor = Colors.white,
    this.fontColorLuminanceAware = true,
    this.selectionBorderColor, // = Colors.blue,
    this.hoverBorderColor, // const(0xffff9800),
    this.textStyle,
    this.spaceBetween = 0.75,
    this.cornerRadius,
    this.builder,
    this.hapticFeedbackOnLongPressSelection = true,
    this.selectionDelay = kLongPressTimeout,
    this.dragDelay =  kLongPressTimeout,
    this.animationDuration = const Duration(seconds: 1),
    this.defaultDuration = const Duration(minutes: 30),
  });

  getHoverBorderColor(BuildContext context) {
    return hoverBorderColor ?? Theme.of(context).colorScheme.primary;
  }
  getSelectionBorderColor(BuildContext context) {
    return selectionBorderColor ?? Theme.of(context).colorScheme.primary;
  }
}