import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/models.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/otp_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/ride/ride_options_screen.dart';
import '../../presentation/screens/ride/driver_matching_screen.dart';
import '../../presentation/screens/ride/driver_assigned_screen.dart';
import '../../presentation/screens/trip/trip_progress_screen.dart';
import '../../presentation/screens/trip/trip_completed_screen.dart';
import '../../presentation/screens/menu/ride_history_screen.dart';

/// App router configuration
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) => const OtpScreen(),
      ),

      // Home
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Search
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final savedPlaceType = extra?['savedPlaceType'] as SavedPlaceType?;
          return SearchScreen(savedPlaceType: savedPlaceType);
        },
      ),

      // Ride Booking Flow
      GoRoute(
        path: '/ride-options',
        name: 'rideOptions',
        builder: (context, state) => const RideOptionsScreen(),
      ),
      GoRoute(
        path: '/driver-matching',
        name: 'driverMatching',
        builder: (context, state) => const DriverMatchingScreen(),
      ),
      GoRoute(
        path: '/driver-assigned',
        name: 'driverAssigned',
        builder: (context, state) => const DriverAssignedScreen(),
      ),

      // Trip
      GoRoute(
        path: '/trip-progress',
        name: 'tripProgress',
        builder: (context, state) => const TripProgressScreen(),
      ),
      GoRoute(
        path: '/trip-completed',
        name: 'tripCompleted',
        builder: (context, state) => const TripCompletedScreen(),
      ),

      // Menu Screens
      GoRoute(
        path: '/ride-history',
        name: 'rideHistory',
        builder: (context, state) => const RideHistoryScreen(),
      ),
    ],

    // Error handler
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.message ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
