import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';
import 'core/providers/app_provider.dart';
import 'core/router/app_router.dart';
import 'services/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: Builder(
        builder: (context) {
          return Provider<AppRouter>(
            create: (_) => AppRouter(context.read<AuthService>()),
            child: Builder(
              builder: (context) {
                final router = context.read<AppRouter>().router;
                final appProvider = context.watch<AppProvider>();
                return MaterialApp.router(
                  title: 'Nursery App',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  themeMode: appProvider.themeMode,
                  routerConfig: router,
                  locale: appProvider.locale,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('ar'),
                    Locale('en'),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
