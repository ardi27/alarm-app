import 'package:alarm/domain/entity/app_error.dart';
import 'package:alarm/domain/entity/no_params.dart';
import 'package:alarm/domain/repository/alarm_repository.dart';
import 'package:alarm/domain/usecase/usecase.dart';
import 'package:dartz/dartz.dart';

class DeleteAlarm extends UseCase<bool,NoParams>{
  final AlarmRepository _repository;

  DeleteAlarm(this._repository);
  @override
  Future<Either<AppError, bool>> call(NoParams params)async {
    return await _repository.deleteAlarm();
  }

}