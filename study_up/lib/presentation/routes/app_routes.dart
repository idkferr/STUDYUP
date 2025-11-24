import 'package:flutter/material.dart';
import '../screens/auth_guard_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/user/login_screen.dart';
import '../screens/user/register_screen.dart';
import '../screens/materias/materias_screen.dart';
import '../screens/materias/materia_form_screen.dart';
import '../screens/calificaciones/calificaciones_screen.dart';
import '../screens/calificaciones/calificacion_form_screen.dart';
import '../screens/calificaciones/simulation_screen.dart';
import '../screens/horario/horario_screen.dart';

class AppRoutes {
  static const String initialRoute = '/auth-guard';

  static final Map<String, WidgetBuilder> routes = {
    '/auth-guard': (context) => const AuthGuardScreen(),
    '/': (context) => const HomeScreen(),
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    '/materias': (context) => const MateriasScreen(),
    '/materia-form': (context) => const MateriaFormScreen(),
    '/calificaciones': (context) => const CalificacionesScreen(),
    '/calificacion-form': (context) => const CalificacionFormScreen(),
    '/simulation': (context) => const SimulationScreen(),
    '/horario': (context) => const HorarioScreen(),
  };
}
