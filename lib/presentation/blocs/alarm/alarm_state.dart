part of 'alarm_bloc.dart';

enum Status { success,failure,loading, deleted, created }

abstract class AlarmState extends Equatable {
  const AlarmState();
  @override
  List<Object?> get props => [];
}

class AlarmInitial extends AlarmState {

}
class AlarmLoading extends AlarmState {

}
class AlarmLoaded extends AlarmState {
  final Alarm? alarm;
  final Status status;
  final String errMessage;
  const AlarmLoaded(this.alarm, this.status, this.errMessage);
  @override
  List<Object?> get props => [alarm,status,errMessage];
  AlarmLoaded copyWith({Alarm? alarm,Status? status,String? errMessage})=>AlarmLoaded(alarm??this.alarm, status??this.status, errMessage??this.errMessage);
}
class AlarmFailure extends AlarmState {
  final String message;

  const AlarmFailure(this.message);
}
