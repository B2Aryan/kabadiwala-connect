import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/localization/language_provider.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/earnings/services/transaction_provider.dart';
import 'features/lots/services/lot_provider.dart';
import 'features/recyclers/services/recycler_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final languageProvider = LanguageProvider();
  await languageProvider.loadSavedLanguage();
  runApp(KabadiwalaConnectApp(languageProvider: languageProvider));
}

class KabadiwalaConnectApp extends StatelessWidget {
  final LanguageProvider? languageProvider;

  const KabadiwalaConnectApp({super.key, this.languageProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              languageProvider ?? (LanguageProvider()..loadSavedLanguage()),
        ),
        ChangeNotifierProvider(create: (_) => LotProvider()),
        ChangeNotifierProvider(create: (_) => RecyclerProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
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
