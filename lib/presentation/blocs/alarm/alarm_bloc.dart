import 'package:alarm/domain/entity/alarm.dart';
import 'package:alarm/domain/entity/no_params.dart';
import 'package:alarm/domain/usecase/add_alarm.dart';
import 'package:alarm/domain/usecase/delete_alarm.dart';
import 'package:alarm/domain/usecase/get_alarm.dart';
import 'package:alarm/domain/usecase/update_alarm.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

part 'alarm_event.dart';
part 'alarm_state.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final GetAlarm getAlarm;
  final AddAlarm addAlarm;
  final DeleteAlarm deleteAlarm;
  final UpdateAlarm updateAlarm;
  AlarmBloc(this.getAlarm, this.addAlarm, this.deleteAlarm, this.updateAlarm) : super(AlarmInitial()) {
    on<FetchAlarmEvent>((event, emit) async {
      emit(AlarmLoading());
      final eith = await getAlarm.call(NoParams());
      eith.fold((l) => emit(AlarmFailure(l.message)), (r) => emit(AlarmLoaded(r, Status.success, '')));
    });
    on<DeleteAlarmEvent>((event, emit) async {
      final currentState = state;
      if(currentState is AlarmLoaded){
        // emit(currentState.copyWith(status: Status.loading));
        final eith = await deleteAlarm.call(NoParams());
        eith.fold((l) => emit(currentState.copyWith(status: Status.failure,errMessage: l.message)), (r) {
          emit(currentState.copyWith(status: Status.deleted, alarm: null));
          add(FetchAlarmEvent());
        });
      }
    });
    on<AddAlarmEvent>((event, emit) async {
      final currentState = state;
      if(currentState is AlarmLoaded){
        emit(currentState.copyWith(status: Status.loading));
        final eith = await addAlarm.call(Alarm(hour: event.hour, minute: event.minute,hasRang: false,duration: 0));
        eith.fold((l) => emit(currentState.copyWith(status: Status.failure,errMessage: l.message)), (r) {
          emit(currentState.copyWith(status: Status.created));
          add(FetchAlarmEvent());
        });
      }
    });
    on<FireAlarmEvent>((event, emit) async {
      final currentState = state;
      if(currentState is AlarmLoaded){
        emit(currentState.copyWith(status: Status.loading));
        final eith = await updateAlarm.call(event.duration);
        eith.fold((l) => emit(currentState.copyWith(status: Status.failure,errMessage: l.message)), (r) {
          emit(currentState.copyWith(status: Status.success));
        });
      }
    });
  }
}
