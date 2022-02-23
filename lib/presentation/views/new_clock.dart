// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/material.dart';
//
// class NewClock extends StatefulWidget {
//   const NewClock({Key? key}) : super(key: key);
//
//   @override
//   _NewClockState createState() => _NewClockState();
// }
//
// class _NewClockState extends State<NewClock> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CircularSliderPaint(child: SizedBox(),
//         baseColor: Colors.red,
//         selectionColor: Colors.green,
//         end: 60,
//         init: 0,
//         intervals: 1,
//         onSelectionChange: (){
//
//         },
//       ),
//     );
//   }
// }
// class BasePainter extends CustomPainter {
//   final Color baseColor;
//
//   late Offset center;
//   late double radius;
//
//   BasePainter({required this.baseColor});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = baseColor
//       ..strokeCap = StrokeCap.round
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 12.0;
//
//     center = Offset(size.width / 2, size.height / 2);
//     radius = min(size.width / 2, size.height / 2);
//
//     canvas.drawCircle(center, radius, paint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return false;
//   }
// }
// class SliderPainter extends CustomPainter {
// double startAngle;
// double endAngle;
// double sweepAngle;
// Color selectionColor;
//
// late Offset initHandler;
// late Offset endHandler;
// late Offset center;
// late double radius;
//
// SliderPainter(
//     {required this.startAngle,
//       required this.endAngle,
//       required this.sweepAngle,
//       required this.selectionColor});
//
// @override
// void paint(Canvas canvas, Size size) {
//   if (startAngle == 0.0 && endAngle == 0.0) return;
//
//   Paint progress = _getPaint(color: selectionColor);
//
//   center = Offset(size.width / 2, size.height / 2);
//   radius = min(size.width / 2, size.height / 2);
//
//   canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
//       -pi / 2 + startAngle, sweepAngle, false, progress);
//
//   Paint handler = _getPaint(color: selectionColor, style: PaintingStyle.fill);
//   Paint handlerOutter = _getPaint(color: selectionColor, width: 2.0);
//
//   // draw handlers
//   initHandler = radiansToCoordinates(center, -pi / 2 + startAngle, radius);
//   canvas.drawCircle(initHandler, 8.0, handler);
//   canvas.drawCircle(initHandler, 12.0, handlerOutter);
//
//   endHandler = radiansToCoordinates(center, -pi / 2 + endAngle, radius);
//   canvas.drawCircle(endHandler, 8.0, handler);
//   canvas.drawCircle(endHandler, 12.0, handlerOutter);
// }
//
// Paint _getPaint({required Color color,double? width,PaintingStyle? style}) =>
//     Paint()
//       ..color = color
//       ..strokeCap = StrokeCap.round
//       ..style = style ?? PaintingStyle.stroke
//       ..strokeWidth = width ?? 12.0;
//
// @override
// bool shouldRepaint(CustomPainter oldDelegate) {
//   return true;
// }
// }
// Offset radiansToCoordinates(Offset center, double radians, double radius) {
//   var dx = center.dx + radius * cos(radians);
//   var dy = center.dy + radius * sin(radians);
//   return Offset(dx, dy);
// }
//
// class CircularSliderPaint extends StatefulWidget {
//   final int init;
//   final int end;
//   final int intervals;
//   final Function onSelectionChange;
//   final Color baseColor;
//   final Color selectionColor;
//   final Widget child;
//
//   const CircularSliderPaint(
//       {required this.intervals,
//         required this.init,
//         required this.end,
//         required this.child,
//         required this.onSelectionChange,
//         required this.baseColor,
//         required this.selectionColor});
//
//   @override
//   _CircularSliderState createState() => _CircularSliderState();
// }
//
// class _CircularSliderState extends State<CircularSliderPaint> {
//   bool _isInitHandlerSelected = false;
//   bool _isEndHandlerSelected = false;
//
//   late SliderPainter _painter;
//
//   /// start angle in radians where we need to locate the init handler
//   late double _startAngle;
//
//   /// end angle in radians where we need to locate the end handler
//   late double _endAngle;
//
//   /// the absolute angle in radians representing the selection
//   late double _sweepAngle;
//
//   @override
//   void initState() {
//     super.initState();
//     _calculatePaintData();
//   }
//
//   // we need to update this widget both with gesture detector but
//   // also when the parent widget rebuilds itself
//   @override
//   void didUpdateWidget(CircularSliderPaint oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.init != widget.init || oldWidget.end != widget.end) {
//       _calculatePaintData();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onPanDown: _onPanDown,
//       onPanUpdate: _onPanUpdate,
//       onPanEnd: _onPanEnd,
//       child: CustomPaint(
//         painter: BasePainter(
//             baseColor: widget.baseColor,),
//         foregroundPainter: _painter,
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: widget.child,
//         ),
//       ),
//     );
//   }
//
//   void _calculatePaintData() {
//     double initPercent = valueToPercentage(widget.init, widget.intervals);
//     double endPercent = valueToPercentage(widget.end, widget.intervals);
//     double sweep = getSweepAngle(initPercent, endPercent);
//
//     _startAngle = percentageToRadians(initPercent);
//     _endAngle = percentageToRadians(endPercent);
//     _sweepAngle = percentageToRadians(sweep.abs());
//
//     _painter = SliderPainter(
//       startAngle: _startAngle,
//       endAngle: _endAngle,
//       sweepAngle: _sweepAngle,
//       selectionColor: widget.selectionColor,
//     );
//   }
//
//   _onPanUpdate(DragUpdateDetails details) {
//     if (!_isInitHandlerSelected && !_isEndHandlerSelected) {
//       return;
//     }
//     if (_painter.center == null) {
//       return;
//     }
//     RenderObject renderBox = context.findRenderObject();
//     var position = renderBox?.globalToLocal(details.globalPosition);
//
//     var angle = coordinatesToRadians(_painter.center, position);
//     var percentage = radiansToPercentage(angle);
//     var newValue = percentageToValue(percentage, widget.intervals);
//
//     if (_isInitHandlerSelected) {
//       widget.onSelectionChange(newValue, widget.end);
//     } else {
//       widget.onSelectionChange(widget.init, newValue);
//     }
//   }
//
//   _onPanEnd(_) {
//     _isInitHandlerSelected = false;
//     _isEndHandlerSelected = false;
//   }
//
//   _onPanDown(DragDownDetails details) {
//     if (_painter == null) {
//       return;
//     }
//     RenderBox renderBox = context.findRenderObject();
//     var position = renderBox.globalToLocal(details.globalPosition);
//     if (position != null) {
//       _isInitHandlerSelected = isPointInsideCircle(
//           position, _painter.initHandler, 12.0);
//       if (!_isInitHandlerSelected) {
//         _isEndHandlerSelected = isPointInsideCircle(
//             position, _painter.endHandler, 12.0);
//       }
//     }
//   }
// }
//
// double percentageToRadians(double percentage) => ((2 * pi * percentage) / 100);
//
// double radiansToPercentage(double radians) {
//   var normalized = radians < 0 ? -radians : 2 * pi - radians;
//   var percentage = ((100 * normalized) / (2 * pi));
//   // TODO we have an inconsistency of pi/2 in terms of percentage and radians
//   return (percentage + 25) % 100;
// }
//
// double coordinatesToRadians(Offset center, Offset coords) {
//   var a = coords.dx - center.dx;
//   var b = center.dy - coords.dy;
//   return atan2(b, a);
// }
//
// Offset radiansToCoordinates(Offset center, double radians, double radius) {
//   var dx = center.dx + radius * cos(radians);
//   var dy = center.dy + radius * sin(radians);
//   return Offset(dx, dy);
// }
//
// double valueToPercentage(int time, int intervals) => (time / intervals) * 100;
//
// int percentageToValue(double percentage, int intervals) =>
//     ((percentage * intervals) / 100).round();
//
// bool isPointInsideCircle(Offset point, Offset center, double rradius) {
//   var radius = rradius * 1.2;
//   return point.dx < (center.dx + radius) &&
//       point.dx > (center.dx - radius) &&
//       point.dy < (center.dy + radius) &&
//       point.dy > (center.dy - radius);
// }
//
// bool isPointAlongCircle(Offset point, Offset center, double radius) {
//   // distance is root(sqr(x2 - x1) + sqr(y2 - y1))
//   // i.e., (7,8) and (3,2) -> 7.21
//   var d1 = pow(point.dx - center.dx, 2);
//   var d2 = pow(point.dy - center.dy, 2);
//   var distance = sqrt(d1 + d2);
//   return (distance - radius).abs() < 10;
// }
//
// double getSweepAngle(double init, double end) {
//   if (end > init) {
//     return end - init;
//   }
//   return (100 - init + end).abs();
// }
//
// List<Offset> getSectionsCoordinatesInCircle(
//     Offset center, double radius, int sections) {
//   var intervalAngle = (pi * 2) / sections;
//   return List<int>.generate(sections, (int index) => index).map((i) {
//     var radians = (pi / 2) + (intervalAngle * i);
//     return radiansToCoordinates(center, radians, radius);
//   }).toList();
// }
//
// bool isAngleInsideRadiansSelection(double angle, double start, double sweep) {
//   var normalized = angle > pi / 2 ? 5 * pi / 2 - angle : pi / 2 - angle;
//   var end = (start + sweep) % (2 * pi);
//   return end > start
//       ? normalized > start && normalized < end
//       : normalized > start || normalized < end;
// }
//
// // this is not 100% accurate but it works
// // we just want to see if a value changed drastically its value
// bool radiansWasModuloed(double current, double previous) {
//   return (previous - current).abs() > (3 * pi / 2);
// }