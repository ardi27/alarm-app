import 'package:alarm/data/datasource/alarm_local_data_source.dart';
import 'package:alarm/domain/entity/alarm.dart';
import 'package:alarm/domain/entity/app_error.dart';
import 'package:alarm/domain/repository/alarm_repository.dart';
import 'package:dartz/dartz.dart';

class AlarmRepositoryImpl implements AlarmRepository{
  final AlarmLocalDataSource _dataSource;

  AlarmRepositoryImpl(this._dataSource);
  @override
  Future<Either<AppError, bool>> addAlarm(Alarm alarm) async{
    try{
      final res = await _dataSource.addAlarm(alarm);
      return Right(res);
    }catch(e){
      return Left(AppError(AppErrorType.database,message: e.toString()));
    }
  }

  @override
  Future<Either<AppError, bool>> deleteAlarm() async{
    try{
      final res = await _dataSource.deleteAlarm();
      return Right(res);
    }catch(e){
      return Left(AppError(AppErrorType.database,message: e.toString()));
    }
  }

  @override
  Future<Either<AppError, List<Alarm>>> getAlarm()async {
    try{
      final List<Alarm> res = await _dataSource.getAlarm();
      return Right(res);
    }catch(e){
      return Left(AppError(AppErrorType.database,message: e.toString()));
    }
  }

  @override
  Future<Either<AppError, bool>> updateAlarm(int duration)async {
    try{
      final res = await _dataSource.updateAlarm(duration);
      return Right(res);
    }catch(e){
      return Left(AppError(AppErrorType.database,message: e.toString()));
    }
  }

}