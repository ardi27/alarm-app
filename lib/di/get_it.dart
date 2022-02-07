import 'package:alarm/data/datasource/alarm_local_data_source.dart';
import 'package:alarm/data/repository/alarm_repository_impl.dart';
import 'package:alarm/domain/repository/alarm_repository.dart';
import 'package:alarm/domain/usecase/add_alarm.dart';
import 'package:alarm/domain/usecase/delete_alarm.dart';
import 'package:alarm/domain/usecase/get_alarm.dart';
import 'package:alarm/presentation/blocs/alarm/alarm_bloc.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.I;
void setup(){
  injectDataSource();
  injectRepository();
  injectUseCase();
  injectBloc();
}
void injectRepository(){
  getIt.registerLazySingleton<AlarmRepository>(() => AlarmRepositoryImpl(getIt()));
}
void injectDataSource(){
  getIt.registerLazySingleton<AlarmLocalDataSource>(() => AlarmLocalDataSourceImpl());
}
void injectUseCase(){
  getIt.registerLazySingleton(() => GetAlarm(getIt()));
  getIt.registerLazySingleton(() => DeleteAlarm(getIt()));
  getIt.registerLazySingleton(() => AddAlarm(getIt()));
}
void injectBloc(){
  getIt.registerFactory(() => AlarmBloc(getIt(),getIt(),getIt()));
}