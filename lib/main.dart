import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SpiceRouteApp());
}

class SpiceRouteApp extends StatefulWidget {
  const SpiceRouteApp({super.key});

  @override
  State<SpiceRouteApp> createState() => _SpiceRouteAppState();
}

class _SpiceRouteAppState extends State<SpiceRouteApp> {
  final AppState _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpiceRoute',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: LoginScreen(appState: _appState),
    );
  }
}
