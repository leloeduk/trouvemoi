import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class RetrouvePieceApp extends StatelessWidget {
  const RetrouvePieceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RetrouvePièce',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
