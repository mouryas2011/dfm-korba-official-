import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/storage/storage_service.dart';
import 'core/localization/app_localizations.dart';

import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/providers/quiz_provider.dart';
import 'presentation/providers/attendance_provider.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/language_provider.dart';

import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local persistence
  await StorageService.init();

  // Enforce portrait mobile orientation as per project requirements
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar styling
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF080D1A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const DfmKorbaApp());
}

class DfmKorbaApp extends StatelessWidget {
  const DfmKorbaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, lang, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkNeumorphicTheme,
            locale: lang.locale,
            supportedLocales: const [
              Locale('en', ''),
              Locale('hi', ''),
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
