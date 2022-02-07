
import 'dart:convert';

Alarm alarmFromJson(String str) => Alarm.fromJson(json.decode(str));

String alarmToJson(Alarm data) => json.encode(data.toJson());

class Alarm {
  Alarm({
    required this.id,
    required this.hour,
    required this.minute,
  });

  int id;
  int hour;
  int minute;

  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
    id: json["id"],
    hour: json["hour"],
    minute: json["minute"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "hour": hour,
    "minute": minute,
  };
}
