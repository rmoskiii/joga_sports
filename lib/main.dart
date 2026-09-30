import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/app_services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Demo mode: dummy data for Ray, no backend.
  // Later: `await Supabase.initialize(...)` and `AppServices.supabase()`.
  final services = AppServices.fake();

  runApp(JogaApp(services: services));
}
