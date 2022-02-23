import 'package:alarm/common/theme.dart';
import 'package:alarm/di/get_it.dart';
import 'package:alarm/presentation/views/clock_view.dart';
import 'package:alarm/presentation/views/new_clock.dart';
import 'package:alarm/presentation/views/temp_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return MaterialApp(
      title: 'Alarm',
      theme: ThemeData(
        primaryColor: AppTheme.kPrimaryColor,
      ),
      builder: EasyLoading.init(),
      home: const ClockView()
    );
  }
}

