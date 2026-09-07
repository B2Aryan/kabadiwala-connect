import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/localization/language_provider.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/lots/services/lot_provider.dart';
import 'features/recyclers/services/recycler_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KabadiwalaConnectApp());
}

class KabadiwalaConnectApp extends StatelessWidget {
  const KabadiwalaConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => LotProvider()),
        ChangeNotifierProvider(create: (_) => RecyclerProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, langProvider, child) {
          return MaterialApp(
            title: langProvider.tr('appName'),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
