import 'package:alarm/domain/entity/alarm.dart';
import 'package:alarm/domain/entity/app_error.dart';
import 'package:dartz/dartz.dart';

abstract class AlarmRepository{
  Future<Either<AppError,Alarm?>> getAlarm();
  Future<Either<AppError,bool>> addAlarm(Alarm alarm);
  Future<Either<AppError,bool>> deleteAlarm();
}