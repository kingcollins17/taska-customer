import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seeker_app/core/designs/app_theme.dart';
import 'package:seeker_app/router/app_router.dart';

class SeekerApp extends StatelessWidget {
  const SeekerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Taska Customer',
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          theme: AppTheme.lightTheme,
          routerConfig: AppRoutes.router,
        );
      },
    );
  }
}
