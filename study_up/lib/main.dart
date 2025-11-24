import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'presentation/routes/app_routes.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialize Firebase for Flutter (JavaScript SDK already initialized for Web)
  try {
    if (kIsWeb) {
      // For web, Firebase is pre-initialized via JavaScript in index.html
      // We still need to initialize for Flutter's Dart layer
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.web,
      );
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    print(
        "✅ Firebase inicializado correctamente para ${kIsWeb ? 'Web' : 'plataforma nativa'}");
  } catch (e) {
    print("❌ Error al inicializar Firebase: $e");
    // Continue with the app even if Firebase fails
  }

  runApp(const ProviderScope(child: StudyUpApp()));
}

class StudyUpApp extends StatelessWidget {
  const StudyUpApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study-UP',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.routes,
      theme: AppTheme.lightTheme,
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
