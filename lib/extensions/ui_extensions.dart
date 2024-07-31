import 'dart:ui';

extension RectExtension on Rect {
  Rect grow(Offset change) {
    return resize(width: width + change.dx, height: height + change.dy);
  }

  Rect shrink(Offset change) {
    return resize(width: width - change.dx, height: height - change.dy);
  }

   Rect resize({double? width, double? height}) {
    return Rect.fromLTWH(
      left,
      top,
      width ?? this.width,
      height ?? this.height,
    );
   }

   Rect move({double? x, double? y}) {
    return Rect.fromLTWH(
      x ?? left,
      y ?? top,
      width,
      height,
    );
   }
}