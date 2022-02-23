
import 'dart:convert';

Alarm alarmFromJson(String str) => Alarm.fromJson(json.decode(str));

String alarmToJson(Alarm data) => json.encode(data.toJson());

class Alarm {
  Alarm({
    required this.hour,
    required this.minute,
    required this.hasRang,
    required this.duration
  });
  int hour;
  int minute;
  bool hasRang;
  int duration;

  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
    hour: json["hour"],
    minute: json["minute"],
    hasRang: json['hasRang'],
    duration: json['duration']
  );

  Map<String, dynamic> toJson() => {
    "hour": hour,
    "minute": minute,
    'hasRang':hasRang,
    'duration':duration
  };
}
