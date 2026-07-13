import 'package:flutter/material.dart';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seeker_app/bootstrap.dart';
import 'package:seeker_app/seeker_app.dart';

import 'core/designs/app_theme.dart';
import 'router/app_router.dart';

void main() {
  bootstrap();
  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: !kReleaseMode,
        builder: (context) => const SeekerApp(),
      ),
    ),
  );
}
