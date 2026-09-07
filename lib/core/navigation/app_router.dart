import 'package:flutter/material.dart';

import '../../features/earnings/earnings_screen.dart';
import '../../features/home/home_dashboard_screen.dart';
import '../../features/lots/create_lot_screen.dart';
import '../../features/lots/lots_screen.dart';
import '../../features/lots/models/ewaste_lot.dart';
import '../../features/onboarding/language_selection_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/recyclers/models/handover_request.dart';
import '../../features/recyclers/models/recycler.dart';
import '../../features/recyclers/recyclers_screen.dart';
import '../../features/recyclers/screens/handover_tracking_screen.dart';
import '../../features/recyclers/screens/recycler_details_screen.dart';
import '../../features/recyclers/screens/request_submitted_screen.dart';
import '../../features/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String language = '/language';
  static const String home = '/home';
  static const String createLot = '/create-lot';
  static const String recyclers = '/recyclers';
  static const String recyclerDetails = '/recycler-details';
  static const String requestSubmitted = '/request-submitted';
  static const String handoverTracking = '/handover-tracking';
  static const String lots = '/lots';
  static const String earnings = '/earnings';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case language:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LanguageSelectionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 350),
        );
      case home:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeDashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
        );
      case createLot:
        return MaterialPageRoute(builder: (_) => const CreateLotScreen());
      case recyclers:
        final matchingLot = settings.arguments as EwasteLot?;
        return MaterialPageRoute(
          builder: (_) => RecyclersScreen(matchingLot: matchingLot),
        );
      case recyclerDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        final recycler =
            args?['recycler'] as Recycler? ??
            const Recycler(
              id: 'REC-DEMO-001',
              name: 'GreenCycle Recycling — Demo',
              distanceKm: 1.8,
              acceptedMaterials: ['copper', 'eWaste'],
              pickupAvailable: true,
              operatingHours: '9:00 AM – 6:00 PM',
              address: 'Industrial Area Phase 2, Pune',
              phone: '+91 98230 XXXXX',
            );
        final matchingLot = args?['matchingLot'] as EwasteLot?;
        return MaterialPageRoute(
          builder: (_) => RecyclerDetailsScreen(
            recycler: recycler,
            matchingLot: matchingLot,
          ),
        );
      case requestSubmitted:
        final req =
            settings.arguments as HandoverRequest? ??
            HandoverRequest(
              id: 'REQ-DEMO-701',
              lotId: 'KC-2026-00125',
              recyclerId: 'REC-DEMO-001',
              recyclerName: 'GreenCycle Recycling — Demo',
              status: HandoverStatus.reviewing,
              createdAt: DateTime.now(),
              estimatedValue: 3600,
              materialName: 'Copper',
              quantity: 5,
              unit: 'kg',
            );
        return MaterialPageRoute(
          builder: (_) => RequestSubmittedScreen(request: req),
        );
      case handoverTracking:
        final req =
            settings.arguments as HandoverRequest? ??
            HandoverRequest(
              id: 'REQ-DEMO-701',
              lotId: 'KC-2026-00125',
              recyclerId: 'REC-DEMO-001',
              recyclerName: 'GreenCycle Recycling — Demo',
              status: HandoverStatus.reviewing,
              createdAt: DateTime.now(),
              estimatedValue: 3600,
              materialName: 'Copper',
              quantity: 5,
              unit: 'kg',
            );
        return MaterialPageRoute(
          builder: (_) => HandoverTrackingScreen(request: req),
        );
      case lots:
        return MaterialPageRoute(builder: (_) => const LotsScreen());
      case earnings:
        return MaterialPageRoute(builder: (_) => const EarningsScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
