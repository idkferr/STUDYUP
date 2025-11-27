import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/user_provider.dart';

/// AuthGuard Screen
/// Verifica si hay un usuario autenticado al iniciar la app
/// - Si hay sesión activa → Redirige a Home
/// - Si no hay sesión → Redirige a Login
class AuthGuardScreen extends ConsumerStatefulWidget {
  const AuthGuardScreen({super.key});

  @override
  ConsumerState<AuthGuardScreen> createState() => _AuthGuardScreenState();
}

class _AuthGuardScreenState extends ConsumerState<AuthGuardScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Wait for the first frame to ensure the provider has initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndNavigate();
    });
  }

  void _checkAuthAndNavigate() async {
    if (_hasNavigated) return;

    // Give the provider a moment to complete the initial check
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final user = ref.read(userProvider);

    _hasNavigated = true;

    if (user != null) {
      // Usuario autenticado → ir a Home
      Navigator.pushReplacementNamed(context, '/');
    } else {
      // No hay usuario → ir a Login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mientras verifica, mostrar splash screen con gradiente
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1565C0), // Azul
              Color(0xFF7E57C2), // Morado
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo circular con ícono
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 60,
                  color: Color(0xFF7E57C2),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Study-UP',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu camino al éxito académico',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
