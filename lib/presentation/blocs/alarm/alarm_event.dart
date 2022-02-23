part of 'alarm_bloc.dart';

abstract class AlarmEvent extends Equatable {
  const AlarmEvent();
  @override
  List<Object> get props => [];
}
class FetchAlarmEvent extends AlarmEvent{}
class AddAlarmEvent extends AlarmEvent{
  final int id, hour, minute;

  const AddAlarmEvent(this.id, this.hour, this.minute);
}
class DeleteAlarmEvent extends AlarmEvent{

}
class FireAlarmEvent extends AlarmEvent{
  final int duration;
  const FireAlarmEvent(this.duration);
}
