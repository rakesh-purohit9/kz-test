import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../widgets/widgets.dart';
import '../menu/navigation_drawer.dart';

/// Home screen with map and "Where to?" search bar
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return AppStrings.goodMorning;
    } else if (hour < 17) {
      return AppStrings.goodAfternoon;
    } else {
      return AppStrings.goodEvening;
    }
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _onSearchTap() {
    context.push('/search');
  }

  void _onSavedPlaceTap(SavedPlace place) {
    if (place.isSet && place.location != null) {
      ref.read(locationProvider.notifier).setDestinationLocation(place.location!);
      context.push('/ride-options');
    } else {
      // Navigate to add place
      context.push('/search', extra: {'savedPlaceType': place.type});
    }
  }

  void _onRecentPlaceTap(RecentPlace recentPlace) {
    ref.read(locationProvider.notifier).setDestinationLocation(recentPlace.location);
    context.push('/ride-options');
  }

  void _recenterMap() {
    // In a real app, this would animate the map to current location
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final authState = ref.watch(authProvider);
    final rideState = ref.watch(rideProvider);

    // If there's an active ride, show the appropriate screen
    if (rideState.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        switch (rideState.flowState) {
          case RideFlowState.searching:
            context.go('/driver-matching');
            break;
          case RideFlowState.driverAssigned:
          case RideFlowState.driverArriving:
          case RideFlowState.driverArrived:
            context.go('/driver-assigned');
            break;
          case RideFlowState.inProgress:
            context.go('/trip-progress');
            break;
          default:
            break;
        }
      });
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppNavigationDrawer(),
      body: Stack(
        children: [
          // Map Background
          _MapView(
            currentLocation: locationState.currentLocation,
          ),

          // Top Search Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  // Search Bar Row
                  Row(
                    children: [
                      // Menu Button
                      CircleIconButton(
                        icon: Icons.menu,
                        onPressed: _openDrawer,
                        size: 48,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Search Bar
                      Expanded(
                        child: GestureDetector(
                          onTap: _onSearchTap,
                          child: Container(
                            height: AppDimensions.searchBarHeight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSm,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.overlayLight,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  AppStrings.whereTo,
                                  style: AppTypography.searchHint,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // GPS Recenter Button
          Positioned(
            right: AppSpacing.md,
            bottom: 280,
            child: CircleIconButton(
              icon: Icons.my_location,
              onPressed: _recenterMap,
              size: AppDimensions.currentLocationButtonSize,
            ),
          ),

          // Bottom Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomCard(
              greeting: _greeting,
              userName: authState.user?.firstName ?? 'there',
              savedPlaces: locationState.savedPlaces,
              recentPlaces: locationState.recentPlaces,
              onSavedPlaceTap: _onSavedPlaceTap,
              onRecentPlaceTap: _onRecentPlaceTap,
              onSearchTap: _onSearchTap,
            ),
          ),
        ],
      ),
    );
  }
}

/// Map view widget (placeholder - in production use google_maps_flutter)
class _MapView extends StatelessWidget {
  final LocationModel? currentLocation;

  const _MapView({this.currentLocation});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8E4E0),
      child: Stack(
        children: [
          // Simulated map grid
          CustomPaint(
            size: Size.infinite,
            painter: _MapGridPainter(),
          ),
          // Current location indicator
          if (currentLocation != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.userLocation,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.userLocation.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Grid painter for simulated map
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.divider.withOpacity(0.5)
      ..strokeWidth = 1;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines
    for (double x = 0; x < size.width; x += 50) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Simulated roads
    final roadPaint = Paint()
      ..color = AppColors.background
      ..strokeWidth = 8;

    // Main horizontal road
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      roadPaint,
    );

    // Main vertical road
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      roadPaint,
    );

    // Secondary roads
    final secondaryRoadPaint = Paint()
      ..color = AppColors.background.withOpacity(0.8)
      ..strokeWidth = 4;

    canvas.drawLine(
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.7, size.height * 0.6),
      secondaryRoadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height * 0.7),
      secondaryRoadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bottom card with saved places and recent locations
class _BottomCard extends StatelessWidget {
  final String greeting;
  final String userName;
  final List<SavedPlace> savedPlaces;
  final List<RecentPlace> recentPlaces;
  final ValueChanged<SavedPlace> onSavedPlaceTap;
  final ValueChanged<RecentPlace> onRecentPlaceTap;
  final VoidCallback onSearchTap;

  const _BottomCard({
    required this.greeting,
    required this.userName,
    required this.savedPlaces,
    required this.recentPlaces,
    required this.onSavedPlaceTap,
    required this.onRecentPlaceTap,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.bottomSheetTopRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.overlayLight,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              width: AppSpacing.bottomSheetHandleWidth,
              height: AppSpacing.bottomSheetHandleHeight,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
              ),
            ),
          ),
          // Greeting
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              '$greeting, $userName',
              style: AppTypography.headlineMedium,
            ),
          ),
          // Saved Places
          if (savedPlaces.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: savedPlaces.map((place) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: place != savedPlaces.last ? AppSpacing.sm : 0,
                      ),
                      child: SavedPlaceCard(
                        place: place,
                        onTap: () => onSavedPlaceTap(place),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          // Recent Places
          if (recentPlaces.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                AppStrings.recentPlaces,
                style: AppTypography.titleSmall,
              ),
            ),
            ...recentPlaces.take(3).map((place) {
              return RecentLocationItem(
                recentPlace: place,
                onTap: () => onRecentPlaceTap(place),
              );
            }),
          ],
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }
}
