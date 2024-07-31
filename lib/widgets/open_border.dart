
import 'dart:math';

import 'package:flutter/material.dart';

import 'sized_color_box.dart';

class OpenBorder extends StatelessWidget {
  final bool isActive;
  final BorderSide border;
  final Color color;
  final Widget child;
  final Size size;
  final Axis orientation;
  final bool isFirst;
  final bool isLast;
  const OpenBorder({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.orientation,
    required this.isActive,
    required this.size,
    required this.border,
    required this.color,
    required this.child,
  });

  final double thickness = 3.0;


  Alignment getMainAlignment() {
    return orientation == Axis.vertical ? isFirst ? Alignment.bottomCenter : Alignment.topCenter : isFirst ? Alignment.centerRight : Alignment.centerLeft;
  }

  Alignment getSideAlignment1() {
    return orientation == Axis.vertical ? isFirst ? Alignment.bottomLeft : Alignment.topLeft : isFirst ? Alignment.topRight : Alignment.topLeft;
  }

  Alignment getSideAlignment2() {
    return orientation == Axis.vertical ? isFirst ? Alignment.bottomRight : Alignment.topRight : isFirst ? Alignment.bottomRight : Alignment.bottomLeft;
  }


  @override
  Widget build(BuildContext context) {
    if (!isActive || (isLast && isFirst)) return child;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          child,
          Align(
            alignment: getMainAlignment(),
            child: SizedColorBox(
              color: color,
              width: orientation == Axis.vertical ? size.width : thickness,
              height: orientation == Axis.vertical ? thickness : size.height,
            ),
          ),
          Align(
             alignment: getSideAlignment1(),
             child: SizedColorBox(
               color: border.color,
               width: orientation == Axis.vertical ? border.width : thickness,
               height: orientation == Axis.vertical ? thickness : border.width,
            ),
          ),
          Align(
            alignment: getSideAlignment2(),
            child: SizedColorBox(
              color: border.color,
              width: orientation == Axis.vertical ? border.width : thickness,
              height: orientation == Axis.vertical ? thickness : border.width,
            ),
          ),
        ],
      ),
    );

  }
}

class BorderPainter extends CustomPainter {
  
  
  @override
  void paint(Canvas canvas, Size size) {
    final canvasRect = Offset.zero & size;
    const rectWidth = 300.0;
    final rect = Rect.fromCircle(
      center: canvasRect.center,
      radius: rectWidth / 2,
    );
    const radius = 16.0;
    const strokeWidth = 6.0;
    const extend = radius + 24.0;
    const arcSize = Size.square(radius * 2);

    canvas.drawPath(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addRRect(
          RRect.fromRectAndRadius(
            rect,
            const Radius.circular(radius),
          ).deflate(strokeWidth / 2),
        )
        ..addRect(canvasRect),
      Paint()..color = Colors.black26,
    );

    canvas.save();
    canvas.translate(rect.left, rect.top);
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final l = i & 1 == 0;
      final t = i & 2 == 0;
      path
        ..moveTo(l ? 0 : rectWidth, t ? extend : rectWidth - extend)
        ..arcTo(
            Offset(l ? 0 : rectWidth - arcSize.width,
                    t ? 0 : rectWidth - arcSize.width) &
                arcSize,
            l ? pi : pi * 2,
            l == t ? pi / 2 : -pi / 2,
            false)
        ..lineTo(l ? extend : rectWidth - extend, t ? 0 : rectWidth);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.deepOrange
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(BorderPainter oldDelegate) => false;
}