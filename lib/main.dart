import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constants/app_colors.dart';
import 'core/di/injection_container.dart';
import 'features/login/presentation/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  initDependencies();
  runApp(const AgicApp());
}

class AgicApp extends StatelessWidget {
  const AgicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        title: 'AGIC',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: AppColors.white,
        ),
        // Keep the design consistent regardless of system font scaling.
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            boldText: false,
            textScaler: TextScaler.noScaling,
          ),
          child: child!,
        ),
        home: child,
      ),
      child: const LoginPage(),
    );
  }
}
