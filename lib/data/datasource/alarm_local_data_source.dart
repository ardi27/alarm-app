import 'dart:convert';

import 'package:alarm/domain/entity/alarm.dart';
import 'package:hive/hive.dart';

abstract class AlarmLocalDataSource{
  Future<Alarm?> getAlarm();
  Future<bool> addAlarm(Alarm alarm);
  Future<bool> deleteAlarm();
}
class AlarmLocalDataSourceImpl implements AlarmLocalDataSource{
  final String boxName = 'alarm_box';
  @override
  Future<bool> addAlarm(Alarm alarm) async{
    final alarmBox = await Hive.openBox(boxName);
    alarmBox.put('alarm', alarm.toJson());
    return true;
  }

  @override
  Future<bool> deleteAlarm() async{
    final alarmBox = await Hive.openBox(boxName);
    alarmBox.delete('alarm');
    return true;
  }

  @override
  Future<Alarm?> getAlarm() async {
    final alarmBox = await Hive.openBox(boxName);
    final res = alarmBox.get('alarm');
    if(res==null){
      return null;
    }

    return Alarm.fromJson(jsonDecode(jsonEncode(res)));
  }
}