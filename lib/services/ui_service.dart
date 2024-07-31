import 'package:flutter/widgets.dart';

class UIService {
  static final instance = UIService._internal();

  UIService._internal();

  BuildContext? topMostContext;
  Widget? topMostContainer;
  final ValueNotifier<Widget?> topMostNotifier = ValueNotifier<Widget?>(null);

  Rect getBounds(BuildContext context) {
    if(!context.mounted) {
      return Rect.zero;
    }
    RenderObject? renderObject = context.findRenderObject();
    if (renderObject == null || !renderObject.attached) {
      return Rect.zero;
    }
    return renderObject.paintBounds;
  }

  Size getSize(BuildContext context) {
    return getBounds(context).size;
  }

  static T? findWidgetByContext<T>(BuildContext context) {
    if (context.widget.runtimeType == T) {
      return context.widget as T;
    }

    return null;
  }
}
