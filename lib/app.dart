import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/config/app_config.dart';
import 'core/di/app_scope.dart';
import 'core/di/app_services.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Root widget: provides services and sets up theme and navigation.
class JogaApp extends StatefulWidget {
  const JogaApp({super.key, required this.services});

  final AppServices services;

  @override
  State<JogaApp> createState() => _JogaAppState();
}

class _JogaAppState extends State<JogaApp> {
  late final GoRouter _router = buildRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: widget.services,
      child: MaterialApp.router(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        routerConfig: _router,
      ),
    );
  }
}
