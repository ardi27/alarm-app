import 'package:alarm/domain/entity/alarm.dart';
import 'package:alarm/domain/entity/app_error.dart';
import 'package:alarm/domain/repository/alarm_repository.dart';
import 'package:alarm/domain/usecase/usecase.dart';
import 'package:dartz/dartz.dart';

class AddAlarm extends UseCase<bool,Alarm>{
  final AlarmRepository _repository;

  AddAlarm(this._repository);
  @override
  Future<Either<AppError, bool>> call(Alarm params)async {
    return await _repository.addAlarm(params);
  }
}