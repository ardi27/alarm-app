import 'dart:convert';

import 'package:alarm/domain/entity/alarm.dart';
import 'package:hive/hive.dart';

abstract class AlarmLocalDataSource{
  Future<List<Alarm>> getAlarm();
  Future<bool> addAlarm(Alarm alarm);
  Future<bool> deleteAlarm();
  Future<bool> updateAlarm(int duration);
}
class AlarmLocalDataSourceImpl implements AlarmLocalDataSource{
  final String boxName = 'alarm_box';
  @override
  Future<bool> addAlarm(Alarm alarm) async{
    final alarmBox = await Hive.openBox(boxName);
    final res = alarmBox.get('alarm_list',defaultValue: []) as List;
    res.insert(0, alarm.toJson());
    alarmBox.put('alarm_list', res);
    return true;
  }

  @override
  Future<bool> deleteAlarm() async{
    final alarmBox = await Hive.openBox(boxName);
    final res = alarmBox.get('alarm_list',defaultValue: []) as List;
    res.removeAt(0);
    alarmBox.put('alarm_list', res);
    return true;
  }

  @override
  Future<List<Alarm>> getAlarm() async {
    final alarmBox = await Hive.openBox(boxName);
    final res = alarmBox.get('alarm_list');
    if(res==null){
      return [];
    }
    print(jsonEncode(res));
    List<Alarm> alarmList=[];
    for (var e in res){
      alarmList.add(Alarm(hour: e['hour'], minute: e['minute'], hasRang: e['hasRang'], duration: e['duration']));
    }
    return alarmList;
  }

  @override
  Future<bool> updateAlarm(int duration) async{
    final alarmBox = await Hive.openBox(boxName);
    final res = alarmBox.get('alarm_list',defaultValue: []) as List;
    List<Alarm> alarmList = res.map((e) => Alarm.fromJson(jsonDecode(jsonEncode(e)))).toList();
    alarmList[0].duration = duration;
    alarmList[0].hasRang = true;
    List alarmUpdated = alarmList.map((e) => e.toJson()).toList();
    alarmBox.put('alarm_list', alarmUpdated);
    return true;
  }
}