import 'package:alarm/domain/entity/app_error.dart';
import 'package:alarm/domain/entity/no_params.dart';
import 'package:alarm/domain/repository/alarm_repository.dart';
import 'package:alarm/domain/usecase/usecase.dart';
import 'package:dartz/dartz.dart';

class UpdateAlarm extends UseCase<bool,int>{
  final AlarmRepository _repository;

  UpdateAlarm(this._repository);
  @override
  Future<Either<AppError, bool>> call(int params)async {
    return await _repository.updateAlarm(params);
  }

}