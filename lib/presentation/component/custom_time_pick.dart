// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:alarm/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';


// Examples can assume:
// late BuildContext context;

const Duration _kDialogSizeAnimationDuration = Duration(milliseconds: 200);
const Duration _kDialAnimateDuration = Duration(milliseconds: 200);
const double _kTwoPi = 2 * math.pi;
const Duration _kVibrateCommitDelay = Duration(milliseconds: 100);

enum _TimePickerMode { hour, minute }

const double _kTimePickerHeaderControlHeight = 80.0;

const double _kTimePickerWidthPortrait = 328.0;
const double _kTimePickerHeightPortrait = 496.0;

const double _kTimePickerHeightPortraitCollapsed = 484.0;

const BorderRadius _kDefaultBorderRadius = BorderRadius.all(Radius.circular(4.0));
const ShapeBorder _kDefaultShape = RoundedRectangleBorder(borderRadius: _kDefaultBorderRadius);

@immutable
class TimePickerEntity {
  const TimePickerEntity({
    required this.selectedTime,
    required this.onTimeChange,
    required this.mode,
    required this.onModeChange,
  });
  final TimeOfDay selectedTime;
  final _TimePickerMode mode;
  final ValueChanged<TimeOfDay> onTimeChange;
  final ValueChanged<_TimePickerMode> onModeChange;
}

class _TimePickerHeader extends StatelessWidget {
  const _TimePickerHeader({
    required this.selectedTime,
    required this.onChanged, required this.mode,
    required this.onModeChange,
  });

  final TimeOfDay selectedTime;
  final _TimePickerMode mode;
  final ValueChanged<TimeOfDay> onChanged;
  final ValueChanged<_TimePickerMode> onModeChange;

  @override
  Widget build(BuildContext context) {
    final TimeOfDayFormat timeOfDayFormat = MaterialLocalizations.of(context).timeOfDayFormat(
      alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat,
    );
    final TimePickerEntity fragmentContext = TimePickerEntity(
      selectedTime: selectedTime,
      onTimeChange: onChanged,
      mode: mode,
      onModeChange: onModeChange
    );

    final EdgeInsets padding;
    double? width;
    final Widget controls;
    padding = const EdgeInsets.symmetric(horizontal: 24.0);
    controls = Column(
      children: <Widget>[
        const SizedBox(height: 16.0),
        SizedBox(
          height: kMinInteractiveDimension * 2,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  // Hour/minutes should not change positions in RTL locales.
                  textDirection: TextDirection.ltr,
                  children: <Widget>[
                    Expanded(child: _HourControl(fragmentContext: fragmentContext)),
                    _StringFragment(timeOfDayFormat: timeOfDayFormat),
                    Expanded(child: _MinuteControl(fragmentContext: fragmentContext)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      width: width,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          controls,
        ],
      ),
    );
  }
}

class _HourMinuteControl extends StatelessWidget {
  const _HourMinuteControl({
    required this.text,
    required this.onTap,
    required this.onDoubleTap,
    required this.isSelected,
  }) : assert(text != null),
        assert(onTap != null),
        assert(isSelected != null);

  final String text;
  final GestureTapCallback onTap;
  final GestureTapCallback onDoubleTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TimePickerThemeData timePickerTheme = TimePickerTheme.of(context).copyWith(hourMinuteTextColor: AppTheme.kPrimaryColor);
    final bool isDark = themeData.colorScheme.brightness == Brightness.dark;
    final Color textColor = timePickerTheme.hourMinuteTextColor
        ?? MaterialStateColor.resolveWith((Set<MaterialState> states) {
          return states.contains(MaterialState.selected)
              ? themeData.colorScheme.primary
              : themeData.colorScheme.onSurface;
        });
    final Color backgroundColor = timePickerTheme.hourMinuteColor
        ?? MaterialStateColor.resolveWith((Set<MaterialState> states) {
          return states.contains(MaterialState.selected)
              ? AppTheme.kPrimaryColor.withOpacity(isDark ? 0.24 : 0.12)
              : Colors.white;
        });
    final TextStyle style = timePickerTheme.hourMinuteTextStyle ?? themeData.textTheme.headline2!;
    final ShapeBorder shape = timePickerTheme.hourMinuteShape ?? _kDefaultShape;

    final Set<MaterialState> states = isSelected ? <MaterialState>{MaterialState.selected} : <MaterialState>{};
    return SizedBox(
      height: _kTimePickerHeaderControlHeight,
      child: Material(
        color: MaterialStateProperty.resolveAs(backgroundColor, states),
        clipBehavior: Clip.antiAlias,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: style.copyWith(color: MaterialStateProperty.resolveAs(textColor, states)),
              textScaleFactor: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
class _HourControl extends StatelessWidget {
  const _HourControl({
    required this.fragmentContext,
  });

  final TimePickerEntity fragmentContext;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final bool alwaysUse24HourFormat = MediaQuery.of(context).alwaysUse24HourFormat;
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final String formattedHour = fragmentContext.selectedTime.hour.toString();

    TimeOfDay hoursFromSelected(int hoursToAdd) {
      final int selectedHour = fragmentContext.selectedTime.hour;
      return fragmentContext.selectedTime.replacing(
        hour: (selectedHour + hoursToAdd) % TimeOfDay.hoursPerDay,
      );
    }

    final TimeOfDay nextHour = hoursFromSelected(1);
    final TimeOfDay previousHour = hoursFromSelected(-1);
    return _HourMinuteControl(
      isSelected: fragmentContext.mode == _TimePickerMode.hour,
      text: formattedHour,
      onTap: Feedback.wrapForTap(() => fragmentContext.onModeChange(_TimePickerMode.hour), context)!,
      onDoubleTap: (){},
    );
  }
}

class _StringFragment extends StatelessWidget {
  const _StringFragment({
    required this.timeOfDayFormat,
  });

  final TimeOfDayFormat timeOfDayFormat;

  String _stringFragmentValue(TimeOfDayFormat timeOfDayFormat) {
    switch (timeOfDayFormat) {
      case TimeOfDayFormat.h_colon_mm_space_a:
      case TimeOfDayFormat.a_space_h_colon_mm:
      case TimeOfDayFormat.H_colon_mm:
      case TimeOfDayFormat.HH_colon_mm:
        return ':';
      case TimeOfDayFormat.HH_dot_mm:
        return '.';
      case TimeOfDayFormat.frenchCanadian:
        return 'h';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TimePickerThemeData timePickerTheme = TimePickerTheme.of(context);
    final TextStyle hourMinuteStyle = timePickerTheme.hourMinuteTextStyle ?? theme.textTheme.headline2!;
    final Color textColor = timePickerTheme.hourMinuteTextColor ?? theme.colorScheme.onSurface;

    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Center(
          child: Text(
            _stringFragmentValue(timeOfDayFormat),
            style: hourMinuteStyle.apply(color: MaterialStateProperty.resolveAs(textColor, <MaterialState>{})),
            textScaleFactor: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Displays the minute fragment.
///
/// When tapped changes time picker dial mode to [_TimePickerMode.minute].
class _MinuteControl extends StatelessWidget {
  const _MinuteControl({
    required this.fragmentContext,
  });

  final TimePickerEntity fragmentContext;

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final String formattedMinute = localizations.formatMinute(fragmentContext.selectedTime);
    final TimeOfDay nextMinute = fragmentContext.selectedTime.replacing(
      minute: (fragmentContext.selectedTime.minute + 1) % TimeOfDay.minutesPerHour,
    );
    final String formattedNextMinute = localizations.formatMinute(nextMinute);
    final TimeOfDay previousMinute = fragmentContext.selectedTime.replacing(
      minute: (fragmentContext.selectedTime.minute - 1) % TimeOfDay.minutesPerHour,
    );
    final String formattedPreviousMinute = localizations.formatMinute(previousMinute);

    return Semantics(
      excludeSemantics: true,
      value: '${localizations.timePickerMinuteModeAnnouncement} $formattedMinute',
      increasedValue: formattedNextMinute,
      onIncrease: () {
        fragmentContext.onTimeChange(nextMinute);
      },
      decreasedValue: formattedPreviousMinute,
      onDecrease: () {
        fragmentContext.onTimeChange(previousMinute);
      },
      child: _HourMinuteControl(
        isSelected: fragmentContext.mode == _TimePickerMode.minute,
        text: formattedMinute,
        onTap: Feedback.wrapForTap(() => fragmentContext.onModeChange(_TimePickerMode.minute), context)!,
        onDoubleTap: (){},
      ),
    );
  }
}


/// Displays the am/pm fragment and provides controls for switching between am
/// and pm.


/// A widget to pad the area around the [_DayPeriodControl]'s inner [Material].

class _TappableLabel {
  _TappableLabel({
    required this.value,
    required this.painter,
    required this.onTap,
  });

  /// The value this label is displaying.
  final int value;

  /// Paints the text of the label.
  final TextPainter painter;

  /// Called when a tap gesture is detected on the label.
  final VoidCallback onTap;
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.primaryLabels,
    required this.secondaryLabels,
    required this.backgroundColor,
    required this.accentColor,
    required this.dotColor,
    required this.theta,
    required this.textDirection,
    required this.selectedValue,
    required this.selectedMinute,
  }) : super(repaint: PaintingBinding.instance!.systemFonts);

  final List<_TappableLabel> primaryLabels;
  final List<_TappableLabel> secondaryLabels;
  final Color backgroundColor;
  final Color accentColor;
  final Color dotColor;
  final double theta;
  final TextDirection textDirection;
  final int selectedValue;
  final int selectedMinute;

  static const double _labelPadding = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.shortestSide / 2.0;
    final Offset center = Offset(size.width / 2.0, size.height / 2.0);
    final Offset centerPoint = center;
    canvas.drawCircle(centerPoint, radius, Paint()..color = backgroundColor);

    final double labelRadius = radius - _labelPadding;
    Offset getOffsetForTheta(double theta) {
      return center + Offset(labelRadius * math.cos(theta), -labelRadius * math.sin(theta));
    }

    void paintLabels(List<_TappableLabel>? labels) {
      if (labels == null)
        return;
      final double labelThetaIncrement = -_kTwoPi / labels.length;
      double labelTheta = math.pi / 2.0;

      for (final _TappableLabel label in labels) {
        final TextPainter labelPainter = label.painter;
        final Offset labelOffset = Offset(-labelPainter.width / 2.0, -labelPainter.height / 2.0);
        labelPainter.paint(canvas, getOffsetForTheta(labelTheta) + labelOffset);
        labelTheta += labelThetaIncrement;
      }
    }

    paintLabels(primaryLabels);

    final Paint selectorPaint = Paint()
      ..color = accentColor;
    final Offset focusedPoint = getOffsetForTheta(theta);
    const double focusedRadius = _labelPadding - 4.0;
    canvas.drawCircle(centerPoint, 4.0, selectorPaint);
    canvas.drawCircle(focusedPoint, focusedRadius, selectorPaint);
    selectorPaint.strokeWidth = 2.0;
    canvas.drawLine(centerPoint, focusedPoint, selectorPaint);

    // Add a dot inside the selector but only when it isn't over the labels.
    // This checks that the selector's theta is between two labels. A remainder
    // between 0.1 and 0.45 indicates that the selector is roughly not above any
    // labels. The values were derived by manually testing the dial.
    final double labelThetaIncrement = -_kTwoPi / primaryLabels.length;
    if (theta % labelThetaIncrement > 0.1 && theta % labelThetaIncrement < 0.45) {
      canvas.drawCircle(focusedPoint, 2.0, selectorPaint..color = dotColor);
    }

    final Rect focusedRect = Rect.fromCircle(
      center: focusedPoint, radius: focusedRadius,
    );
    canvas
      ..save()
      ..clipPath(Path()..addOval(focusedRect));
    paintLabels(secondaryLabels);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DialPainter oldPainter) {
    return oldPainter.primaryLabels != primaryLabels
        || oldPainter.secondaryLabels != secondaryLabels
        || oldPainter.backgroundColor != backgroundColor
        || oldPainter.accentColor != accentColor
        || oldPainter.theta != theta;
  }
}

class _Dial extends StatefulWidget {
  const _Dial({
    required this.selectedTime,
    required this.mode,
    required this.use24HourDials,
    required this.onChanged,
    required this.onHourSelected,
  });

  final TimeOfDay selectedTime;
  final _TimePickerMode mode;
  final bool use24HourDials;
  final ValueChanged<TimeOfDay>? onChanged;
  final VoidCallback? onHourSelected;

  @override
  _DialState createState() => _DialState();
}

class _DialState extends State<_Dial> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _thetaController = AnimationController(
      duration: _kDialAnimateDuration,
      vsync: this,
    );
    _thetaTween = Tween<double>(begin: _getThetaForTime(widget.selectedTime));
    _theta = _thetaController
        .drive(CurveTween(curve: standardEasing))
        .drive(_thetaTween)
      ..addListener(() => setState(() { /* _theta.value has changed */ }));
  }

  late ThemeData themeData;
  late MaterialLocalizations localizations;
  late MediaQueryData media;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMediaQuery(context));
    themeData = Theme.of(context);
    localizations = MaterialLocalizations.of(context);
    media = MediaQuery.of(context);
  }

  @override
  void didUpdateWidget(_Dial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode != oldWidget.mode || widget.selectedTime != oldWidget.selectedTime) {
      if (!_dragging) {
        _animateTo(_getThetaForTime(widget.selectedTime));
      }
    }
  }

  @override
  void dispose() {
    _thetaController.dispose();
    super.dispose();
  }

  late Tween<double> _thetaTween;
  late Animation<double> _theta;
  late AnimationController _thetaController;
  bool _dragging = false;

  static double _nearest(double target, double a, double b) {
    return ((target - a).abs() < (target - b).abs()) ? a : b;
  }

  void _animateTo(double targetTheta) {
    final double currentTheta = _theta.value;
    double beginTheta = _nearest(targetTheta, currentTheta, currentTheta + _kTwoPi);
    beginTheta = _nearest(targetTheta, beginTheta, currentTheta - _kTwoPi);
    _thetaTween
      ..begin = beginTheta
      ..end = targetTheta;
    _thetaController
      ..value = 0.0
      ..forward();
  }

  double _getThetaForTime(TimeOfDay time) {
    final int hoursFactor = widget.use24HourDials ? TimeOfDay.hoursPerDay : TimeOfDay.hoursPerPeriod;
    final double fraction = widget.mode == _TimePickerMode.hour
        ? (time.hour / hoursFactor) % hoursFactor
        : (time.minute / TimeOfDay.minutesPerHour) % TimeOfDay.minutesPerHour;
    return (math.pi / 2.0 - fraction * _kTwoPi) % _kTwoPi;
  }

  TimeOfDay _getTimeForTheta(double theta, {bool roundMinutes = false}) {
    final double fraction = (0.25 - (theta % _kTwoPi) / _kTwoPi) % 1.0;
    if (widget.mode == _TimePickerMode.hour) {
      int newHour;
      if (widget.use24HourDials) {
        newHour = (fraction * TimeOfDay.hoursPerDay).round() % TimeOfDay.hoursPerDay;
      } else {
        newHour = (fraction * TimeOfDay.hoursPerPeriod).round() % TimeOfDay.hoursPerPeriod;
        newHour = newHour + widget.selectedTime.periodOffset;
      }
      return widget.selectedTime.replacing(hour: newHour);
    } else {
      int minute = (fraction * TimeOfDay.minutesPerHour).round() % TimeOfDay.minutesPerHour;
      if (roundMinutes) {
        // Round the minutes to nearest 5 minute interval.
        minute = ((minute + 2) ~/ 5) * 5 % TimeOfDay.minutesPerHour;
      }
      return widget.selectedTime.replacing(minute: minute);
    }
  }

  TimeOfDay _notifyOnChangedIfNeeded({ bool roundMinutes = false }) {
    final TimeOfDay current = _getTimeForTheta(_theta.value, roundMinutes: roundMinutes);
    if (widget.onChanged == null)
      return current;
    if (current != widget.selectedTime)
      widget.onChanged!(current);
    return current;
  }

  void _updateThetaForPan({ bool roundMinutes = false }) {
    setState(() {
      final Offset offset = _position! - _center!;
      double angle = (math.atan2(offset.dx, offset.dy) - math.pi / 2.0) % _kTwoPi;
      if (roundMinutes) {
        angle = _getThetaForTime(_getTimeForTheta(angle, roundMinutes: roundMinutes));
      }
      _thetaTween
        ..begin = angle
        ..end = angle; // The controller doesn't animate during the pan gesture.
    });
  }

  Offset? _position;
  Offset? _center;

  void _handlePanStart(DragStartDetails details) {
    assert(!_dragging);
    _dragging = true;
    final RenderBox box = context.findRenderObject()! as RenderBox;
    _position = box.globalToLocal(details.globalPosition);
    _center = box.size.center(Offset.zero);
    _updateThetaForPan();
    _notifyOnChangedIfNeeded();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _position = _position! + details.delta;
    _updateThetaForPan();
    _notifyOnChangedIfNeeded();
  }

  void _handlePanEnd(DragEndDetails details) {
    assert(_dragging);
    _dragging = false;
    _position = null;
    _center = null;
    _animateTo(_getThetaForTime(widget.selectedTime));
    if (widget.mode == _TimePickerMode.hour) {
      widget.onHourSelected?.call();
    }
  }


  void _selectHour(int hour) {
    _announceToAccessibility(context, localizations.formatDecimal(hour));
    final TimeOfDay time;
    if (widget.mode == _TimePickerMode.hour && widget.use24HourDials) {
      time = TimeOfDay(hour: hour, minute: widget.selectedTime.minute);
    } else {
      if (widget.selectedTime.period == DayPeriod.am) {
        time = TimeOfDay(hour: hour, minute: widget.selectedTime.minute);
      } else {
        time = TimeOfDay(hour: hour + TimeOfDay.hoursPerPeriod, minute: widget.selectedTime.minute);
      }
    }
    final double angle = _getThetaForTime(time);
    _thetaTween
      ..begin = angle
      ..end = angle;
    _notifyOnChangedIfNeeded();
  }

  void _selectMinute(int minute) {
    _announceToAccessibility(context, localizations.formatDecimal(minute));
    final TimeOfDay time = TimeOfDay(
      hour: widget.selectedTime.hour,
      minute: minute,
    );
    final double angle = _getThetaForTime(time);
    _thetaTween
      ..begin = angle
      ..end = angle;
    _notifyOnChangedIfNeeded();
  }


  static const List<TimeOfDay> _twentyFourHours = <TimeOfDay>[
    TimeOfDay(hour: 0, minute: 0),
    TimeOfDay(hour: 2, minute: 0),
    TimeOfDay(hour: 4, minute: 0),
    TimeOfDay(hour: 6, minute: 0),
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 18, minute: 0),
    TimeOfDay(hour: 20, minute: 0),
    TimeOfDay(hour: 22, minute: 0),
  ];
  List<_TappableLabel> _build24HourRing(TextTheme textTheme, Color color) => <_TappableLabel>[
    for (final TimeOfDay timeOfDay in _twentyFourHours)
      _buildTappableLabel(
        textTheme,
        color,
        timeOfDay.hour,
        timeOfDay.hour.toString(),
            () {
          _selectHour(timeOfDay.hour);
        },
      ),
  ];

  _TappableLabel _buildTappableLabel(TextTheme textTheme, Color color, int value, String label, VoidCallback onTap) {
    final TextStyle style = textTheme.bodyText1!.copyWith(color: color);
    final double labelScaleFactor = math.min(MediaQuery.of(context).textScaleFactor, 2.0);
    return _TappableLabel(
      value: value,
      painter: TextPainter(
        text: TextSpan(style: style, text: label),
        textDirection: TextDirection.ltr,
        textScaleFactor: labelScaleFactor,
      )..layout(),
      onTap: onTap,
    );
  }

  List<_TappableLabel> _buildMinutes(TextTheme textTheme, Color color) {
    const List<TimeOfDay> _minuteMarkerValues = <TimeOfDay>[
      TimeOfDay(hour: 0, minute: 0),
      TimeOfDay(hour: 0, minute: 5),
      TimeOfDay(hour: 0, minute: 10),
      TimeOfDay(hour: 0, minute: 15),
      TimeOfDay(hour: 0, minute: 20),
      TimeOfDay(hour: 0, minute: 25),
      TimeOfDay(hour: 0, minute: 30),
      TimeOfDay(hour: 0, minute: 35),
      TimeOfDay(hour: 0, minute: 40),
      TimeOfDay(hour: 0, minute: 45),
      TimeOfDay(hour: 0, minute: 50),
      TimeOfDay(hour: 0, minute: 55),
    ];

    return <_TappableLabel>[
      for (final TimeOfDay timeOfDay in _minuteMarkerValues)
        _buildTappableLabel(
          textTheme,
          color,
          timeOfDay.minute,
          localizations.formatMinute(timeOfDay),
              () {
            _selectMinute(timeOfDay.minute);
          },
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TimePickerThemeData pickerTheme = TimePickerTheme.of(context);
    final Color backgroundColor = pickerTheme.dialBackgroundColor ?? themeData.colorScheme.onBackground.withOpacity(0.12);
    final Color primaryLabelColor = MaterialStateProperty.resolveAs(pickerTheme.dialTextColor, <MaterialState>{}) ?? themeData.colorScheme.onSurface;
    final Color secondaryLabelColor = MaterialStateProperty.resolveAs(pickerTheme.dialTextColor, <MaterialState>{MaterialState.selected}) ?? themeData.colorScheme.onPrimary;
    List<_TappableLabel> primaryLabels;
    List<_TappableLabel> secondaryLabels;
    final int selectedDialValue;
    switch (widget.mode) {
      case _TimePickerMode.hour:
        selectedDialValue = widget.selectedTime.hour;
        primaryLabels = _build24HourRing(theme.textTheme, primaryLabelColor);
        secondaryLabels = _build24HourRing(theme.textTheme, secondaryLabelColor);
        break;
      case _TimePickerMode.minute:
        selectedDialValue = widget.selectedTime.minute;
        primaryLabels = _buildMinutes(theme.textTheme, primaryLabelColor);
        secondaryLabels = _buildMinutes(theme.textTheme, secondaryLabelColor);
        break;
    }
    return GestureDetector(
      excludeFromSemantics: true,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      // onTapUp: _handleTapUp,
      child: CustomPaint(
        key: const ValueKey<String>('time-picker-dial'),
        painter: _DialPainter(
          selectedValue: selectedDialValue,
          primaryLabels: primaryLabels,
          secondaryLabels: secondaryLabels,
          backgroundColor: backgroundColor,
          accentColor: Theme.of(context).primaryColor,
          dotColor: theme.colorScheme.surface,
          theta: _theta.value,
          selectedMinute: 33,
          textDirection: Directionality.of(context),
        ),
      ),
    );
  }
}



class _HourMinuteTextField extends StatefulWidget {
  const _HourMinuteTextField({
    Key? key,
    required this.selectedTime,
    required this.isHour,
    required this.autofocus,
    required this.style,
    required this.semanticHintText,
    required this.validator,
    required this.onSavedSubmitted,
    this.restorationId,
    this.onChanged,
  }) : super(key: key);

  final TimeOfDay selectedTime;
  final bool isHour;
  final bool? autofocus;
  final TextStyle style;
  final String semanticHintText;
  final FormFieldValidator<String> validator;
  final ValueChanged<String?> onSavedSubmitted;
  final ValueChanged<String>? onChanged;
  final String? restorationId;

  @override
  _HourMinuteTextFieldState createState() => _HourMinuteTextFieldState();
}

class _HourMinuteTextFieldState extends State<_HourMinuteTextField> with RestorationMixin {
  final RestorableTextEditingController controller = RestorableTextEditingController();
  final RestorableBool controllerHasBeenSet = RestorableBool(false);
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode()..addListener(() {
      setState(() { }); // Rebuild.
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only set the text value if it has not been populated with a localized
    // version yet.
    if (!controllerHasBeenSet.value) {
      controllerHasBeenSet.value = true;
      controller.value.text = _formattedValue;
    }
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(controller, 'text_editing_controller');
    registerForRestoration(controllerHasBeenSet, 'has_controller_been_set');
  }

  String get _formattedValue {
    final bool alwaysUse24HourFormat = MediaQuery.of(context).alwaysUse24HourFormat;
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    return !widget.isHour ? localizations.formatMinute(widget.selectedTime) : localizations.formatHour(
      widget.selectedTime,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TimePickerThemeData timePickerTheme = TimePickerTheme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    final InputDecorationTheme? inputDecorationTheme = timePickerTheme.inputDecorationTheme;
    InputDecoration inputDecoration;
    if (inputDecorationTheme != null) {
      inputDecoration = const InputDecoration().applyDefaults(inputDecorationTheme);
    } else {
      inputDecoration = InputDecoration(
        contentPadding: EdgeInsets.zero,
        filled: true,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),
        hintStyle: widget.style.copyWith(color: colorScheme.onSurface.withOpacity(0.36)),
        errorStyle: const TextStyle(fontSize: 0.0, height: 0.0), // Prevent the error text from appearing.
      );
    }
    final Color unfocusedFillColor = timePickerTheme.hourMinuteColor ?? colorScheme.onSurface.withOpacity(0.12);

    final String? hintText = MediaQuery.of(context).accessibleNavigation || ui.window.semanticsEnabled
        ? widget.semanticHintText
        : (focusNode.hasFocus ? null : _formattedValue);
    inputDecoration = inputDecoration.copyWith(
      hintText: hintText,
      fillColor: focusNode.hasFocus ? Colors.transparent : inputDecorationTheme?.fillColor ?? unfocusedFillColor,
    );

    return SizedBox(
      height: _kTimePickerHeaderControlHeight,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: UnmanagedRestorationScope(
          bucket: bucket,
          child: TextFormField(
            restorationId: 'hour_minute_text_form_field',
            autofocus: widget.autofocus ?? false,
            expands: true,
            maxLines: null,
            inputFormatters: <TextInputFormatter>[
              LengthLimitingTextInputFormatter(2),
            ],
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: widget.style.copyWith(color: timePickerTheme.hourMinuteTextColor ?? colorScheme.onSurface),
            controller: controller.value,
            decoration: inputDecoration,
            validator: widget.validator,
            onEditingComplete: () => widget.onSavedSubmitted(controller.value.text),
            onSaved: widget.onSavedSubmitted,
            onFieldSubmitted: widget.onSavedSubmitted,
            onChanged: widget.onChanged,
          ),
        ),
      ),
    );
  }
}

class CustomTimePicker extends StatefulWidget {
  const CustomTimePicker({
    Key? key,
    required this.initialTime,
    required this.onTimeChange,
  }):
        super(key: key);

  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeChange;

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

// A restorable [TimePickerEntryMode] value.
//
// This serializes each entry as a unique `int` value.
class _RestorableTimePickerEntryMode extends RestorableValue<TimePickerEntryMode> {
  _RestorableTimePickerEntryMode(
      TimePickerEntryMode defaultValue,
      ) : _defaultValue = defaultValue;

  final TimePickerEntryMode _defaultValue;

  @override
  TimePickerEntryMode createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(TimePickerEntryMode? oldValue) {
    assert(debugIsSerializableForRestoration(value.index));
    notifyListeners();
  }

  @override
  TimePickerEntryMode fromPrimitives(Object? data) => TimePickerEntryMode.values[data! as int];

  @override
  Object? toPrimitives() => value.index;
}

// A restorable [_RestorableTimePickerEntryMode] value.
//
// This serializes each entry as a unique `int` value.
class _RestorableTimePickerMode extends RestorableValue<_TimePickerMode> {
  _RestorableTimePickerMode(
      _TimePickerMode defaultValue,
      ) : _defaultValue = defaultValue;

  final _TimePickerMode _defaultValue;

  @override
  _TimePickerMode createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(_TimePickerMode? oldValue) {
    assert(debugIsSerializableForRestoration(value.index));
    notifyListeners();
  }

  @override
  _TimePickerMode fromPrimitives(Object? data) => _TimePickerMode.values[data! as int];

  @override
  Object? toPrimitives() => value.index;
}

// A restorable [_RestorableTimePickerEntryMode] value.
//
// This serializes each entry as a unique `int` value.
//
// This value can be null.
class _RestorableTimePickerModeN extends RestorableValue<_TimePickerMode?> {
  _RestorableTimePickerModeN(
      _TimePickerMode? defaultValue,
      ) : _defaultValue = defaultValue;

  final _TimePickerMode? _defaultValue;

  @override
  _TimePickerMode? createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(_TimePickerMode? oldValue) {
    assert(debugIsSerializableForRestoration(value?.index));
    notifyListeners();
  }

  @override
  _TimePickerMode fromPrimitives(Object? data) => _TimePickerMode.values[data! as int];

  @override
  Object? toPrimitives() => value?.index;
}

class _CustomTimePickerState extends State<CustomTimePicker>  {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final _RestorableTimePickerEntryMode _entryMode = _RestorableTimePickerEntryMode(TimePickerEntryMode.input);
  final _RestorableTimePickerMode _mode = _RestorableTimePickerMode(_TimePickerMode.hour);
  final _RestorableTimePickerModeN _lastModeAnnounced = _RestorableTimePickerModeN(null);
  final RestorableBool _autoValidate = RestorableBool(false);
  final RestorableBoolN _autofocusHour = RestorableBoolN(null);
  final RestorableBoolN _autofocusMinute = RestorableBoolN(null);
  final RestorableBool _announcedInitialTime = RestorableBool(false);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
    _announceInitialTimeOnce();
    _announceModeOnce();
  }

  RestorableTimeOfDay get selectedTime => _selectedTime;
  late final RestorableTimeOfDay _selectedTime = RestorableTimeOfDay(widget.initialTime);

  Timer? _vibrateTimer;
  late MaterialLocalizations localizations;


  void _handleModeChanged(_TimePickerMode mode) {
    setState(() {
      _mode.value = mode;
      _announceModeOnce();
    });
  }

  void _handleEntryModeToggle() {
    setState(() {
      switch (_entryMode.value) {
        case TimePickerEntryMode.dial:
          _autoValidate.value = false;
          _entryMode.value = TimePickerEntryMode.input;
          break;
        case TimePickerEntryMode.input:
          _formKey.currentState!.save();
          _autofocusHour.value = false;
          _autofocusMinute.value = false;
          _entryMode.value = TimePickerEntryMode.dial;
          break;
      }
    });
  }

  void _announceModeOnce() {
    if (_lastModeAnnounced.value == _mode.value) {
      // Already announced it.
      return;
    }

    switch (_mode.value) {
      case _TimePickerMode.hour:
        _announceToAccessibility(context, localizations.timePickerHourModeAnnouncement);
        break;
      case _TimePickerMode.minute:
        _announceToAccessibility(context, localizations.timePickerMinuteModeAnnouncement);
        break;
    }
    _lastModeAnnounced.value = _mode.value;
  }

  void _announceInitialTimeOnce() {

    final MediaQueryData media = MediaQuery.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    _announceToAccessibility(
      context,
      localizations.formatTimeOfDay(widget.initialTime, alwaysUse24HourFormat: media.alwaysUse24HourFormat),
    );
  }

  void _handleTimeChanged(TimeOfDay value) {
    setState(() {
      _selectedTime.value = value;
      widget.onTimeChange(value);
    });
  }

  void _handleHourDoubleTapped() {
    _autofocusHour.value = true;
    _handleEntryModeToggle();
  }

  void _handleMinuteDoubleTapped() {
    _autofocusMinute.value = true;
    _handleEntryModeToggle();
  }

  void _handleHourSelected() {
    setState(() {
      // _mode.value = _TimePickerMode.minute;
    });
  }

  Size _dialogSize(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double textScaleFactor = math.min(MediaQuery.of(context).textScaleFactor, 1.1);

    final double timePickerWidth;
    final double timePickerHeight;
    timePickerWidth = _kTimePickerWidthPortrait;
    timePickerHeight = theme.materialTapTargetSize == MaterialTapTargetSize.padded
        ? _kTimePickerHeightPortrait
        : _kTimePickerHeightPortraitCollapsed;
    return Size(timePickerWidth, timePickerHeight * textScaleFactor);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final MediaQueryData media = MediaQuery.of(context);
    const bool use24HourDials = true;
    final Orientation orientation = media.orientation;

    final Widget picker;
    final Widget dial = Padding(
      padding: orientation == Orientation.portrait ? const EdgeInsets.symmetric(horizontal: 36, vertical: 24) : const EdgeInsets.all(24),
      child: ExcludeSemantics(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _Dial(
                mode: _mode.value,
                use24HourDials: use24HourDials,
                selectedTime: _selectedTime.value,
                onChanged: _handleTimeChanged,
                onHourSelected: _handleHourSelected,
              ),
            ],
          ),
        ),
      ),
    );

    final Widget header = _TimePickerHeader(
      selectedTime: _selectedTime.value,
      mode: _mode.value,
      onModeChange: _handleModeChanged,
      onChanged: _handleTimeChanged,

    );
    picker = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        header,
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Dial grows and shrinks with the available space.
              Expanded(child: dial),
            ],
          ),
        ),
      ],
    );

    final Size dialogSize = _dialogSize(context);
    return AnimatedContainer(
      alignment: Alignment.center,
      width: dialogSize.width,
      height: 400,
      duration: _kDialogSizeAnimationDuration,
      curve: Curves.easeIn,
      child: picker,
    );
  }

  @override
  void dispose() {
    _vibrateTimer?.cancel();
    _vibrateTimer = null;
    super.dispose();
  }
}
void _announceToAccessibility(BuildContext context, String message) {
  SemanticsService.announce(message, Directionality.of(context));
}
