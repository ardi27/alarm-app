import 'dart:convert';
import 'package:alarm/presentation/blocs/alarm/alarm_bloc.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:alarm/common/theme.dart';
import 'package:d_chart/d_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class NotificationUtils {
  NotificationUtils._();
  static final _notification = FlutterLocalNotificationsPlugin();
  static Future _notificationDetail() async {
    return const NotificationDetails(
        android: AndroidNotificationDetails('1', 'alarm',
            channelDescription: 'Alarm purpose', importance: Importance.max),
        iOS: IOSNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true));
  }

  static Future scheduleAlarm(
      {required int id,
      required int hour,
      required int minute,
      String? title,
      String? body,
      String? payload}) async {
    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    tz.TZDateTime tzTimeNow = tz.TZDateTime.now(tz.local);
    tz.TZDateTime alarmTime = tz.TZDateTime.local(DateTime.now().year,
        DateTime.now().month, DateTime.now().day, hour, minute);
    if (alarmTime.isBefore(tzTimeNow)) {
      alarmTime =  alarmTime.add(const Duration(days: 1));
    }
    _notification.zonedSchedule(
        id, title, body, alarmTime, await _notificationDetail(),
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);
  }

  static Future init(BuildContext context,AlarmBloc alarmBloc) async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');
    const initializationSettingIOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);
    const initializationSetting = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingIOS);
    await _notification.initialize(initializationSetting,
        onSelectNotification: (String? payload) {
      print('received $payload');
      if (payload != null) {
        int hourAlarm = jsonDecode(payload)['jam'] as int;
        int minuteAlarm = jsonDecode(payload)['menit'] as int;
        int beda = ((DateTime.now().hour * 3600) +
                (DateTime.now().minute * 60) +
                (DateTime.now().second)) -
            ((hourAlarm * 3600) + (minuteAlarm * 60));
        showDialog(
            context: context,
            builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  insetPadding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 200,
                        padding: const EdgeInsets.all(20),
                        child: DChartBar(
                          data: [
                            {
                              'id': 'Alarm ',
                              'data': [
                                {
                                  'domain':
                                      '${DateTime.now().hour}:${DateTime.now().minute < 10 ? '0${DateTime.now().minute}' : DateTime.now().minute}',
                                  'measure': beda
                                },
                              ],
                            },
                          ],
                          domainLabelPaddingToAxisLine: 16,
                          axisLineTick: 2,
                          yAxisTitle: 'Lama menyala\n(detik)',
                          xAxisTitle: 'Jam alarm',
                          axisLinePointTick: 2,
                          axisLinePointWidth: 10,
                          axisLineColor: AppTheme.kPrimaryColor,
                          measureLabelPaddingToAxisLine: 16,
                          barColor: (barData, index, id) =>
                              AppTheme.kPrimaryColor,
                          showBarValue: true,
                        ),
                      ),
                    ],
                  ),
                )).then((value) => alarmBloc.add(DeleteAlarmEvent()));
      }
    });
  }
  static Future deleteAlarmNotification()async{
    _notification.cancelAll();
  }
}
