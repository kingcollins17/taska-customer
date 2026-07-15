import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seeker_app/core/designs/app_theme.dart';
import 'package:seeker_app/router/app_router.dart';

import 'package:seeker_app/core/providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SeekerApp extends ConsumerWidget {
  const SeekerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

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
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: AppRoutes.router,
        );
      },
    );
  }
}
