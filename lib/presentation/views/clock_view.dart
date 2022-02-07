import 'dart:convert';

import 'package:alarm/common/extension/notification_utils.dart';
import 'package:alarm/common/theme.dart';
import 'package:alarm/di/get_it.dart';
import 'package:alarm/presentation/blocs/alarm/alarm_bloc.dart';
import 'package:alarm/presentation/component/custom_time_pick.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ClockView extends StatefulWidget {
  const ClockView({Key? key}) : super(key: key);

  @override
  State<ClockView> createState() => _ClockViewState();
}

class _ClockViewState extends State<ClockView> {
  late AlarmBloc alarmBloc;
  late TimeOfDay time;
  @override
  void initState() {
    super.initState();
    alarmBloc = getIt<AlarmBloc>();
    alarmBloc.add(FetchAlarmEvent());
    NotificationUtils.init(context,alarmBloc);
    time = TimeOfDay.now();
  }

  @override
  void dispose() {
    super.dispose();
    alarmBloc.close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => alarmBloc,
      child: Scaffold(
        body: BlocConsumer<AlarmBloc, AlarmState>(
          listener: (context,state){
            if(state is AlarmLoaded){
              if(state.status == Status.loading){
                EasyLoading.show(status: 'Loading',maskType: EasyLoadingMaskType.black,dismissOnTap: false);
              }else if(state.status==Status.deleted){
                EasyLoading.dismiss();
                EasyLoading.showSuccess('Berhasil menghapus alarm');
              }else if(state.status == Status.created){
                EasyLoading.dismiss();
                EasyLoading.showSuccess('Berhasil menambah alarm');
              }else if(state.status == Status.failure){
                EasyLoading.dismiss();
                EasyLoading.showError(state.errMessage);
              }
            }
          },
          builder: (context, state) {
            if (state is AlarmLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if(state is AlarmFailure){
              return Center(child: Text(state.message),);
            }else if (state is AlarmLoaded) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTimePicker(
                      initialTime: time,
                      onTimeChange: (value) {
                        time = value;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    state.alarm!=null?Column(
                      children: [
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Alarm sudah diatur',style: TextStyle(fontWeight: FontWeight.bold),),
                                Text('Jam : ${state.alarm?.hour}',style: const TextStyle(color: Colors.black54),),
                                Text('Menit : ${state.alarm?.minute}',style: const TextStyle(color: Colors.black54),),
                              ],
                            ),
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.kPrimaryColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                          ),
                          onPressed: () {
                            alarmBloc.add(DeleteAlarmEvent());
                            NotificationUtils.deleteAlarmNotification();
                          },
                          child: const Text('Hapus alarm' ,style: TextStyle(color: AppTheme.kPrimaryColor,fontWeight: FontWeight.bold),),
                        ),
                      ],
                    ): const SizedBox(),
                    state.alarm == null
                        ? TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                              ),
                              backgroundColor: AppTheme.kPrimaryColor,
                            ),
                            onPressed: () {
                              NotificationUtils.scheduleAlarm(
                                id: 1,
                                hour: time.hour,
                                minute: time.minute,
                                body: 'Alarm diatur jam ${time.hour<10?'0${time.hour}':time.hour}:${time.minute<10?'0${time.minute}':time.minute}',
                                title: 'Alarm',
                                payload: jsonEncode(
                                  {
                                    'jam': time.hour,
                                    'menit': time.minute
                                  },
                                ),
                              );
                              alarmBloc.add(AddAlarmEvent(1, time.hour, time.minute));
                            },
                            child: const Text('Atur alarm', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),))
                        : const SizedBox()
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
