import 'package:alarm/domain/entity/alarm.dart';
import 'package:alarm/domain/entity/app_error.dart';
import 'package:alarm/domain/entity/no_params.dart';
import 'package:alarm/domain/repository/alarm_repository.dart';
import 'package:alarm/domain/usecase/usecase.dart';
import 'package:dartz/dartz.dart';

class GetAlarm extends UseCase<Alarm?,NoParams>{
  final AlarmRepository _repository;

  GetAlarm(this._repository);
  @override
  Future<Either<AppError, Alarm?>> call(NoParams params)async {
    return await _repository.getAlarm();
  }
}