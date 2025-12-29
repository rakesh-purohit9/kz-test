import '../models/models.dart';

/// Mock data for the app
class MockData {
  MockData._();

  // Mock user
  static UserModel get currentUser => UserModel(
        id: 'user_001',
        phoneNumber: '+14155551234',
        firstName: 'Alex',
        lastName: 'Johnson',
        email: 'alex.johnson@email.com',
        photoUrl: '',
        rating: 4.92,
        totalTrips: 127,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      );

  // Mock drivers
  static List<DriverModel> get drivers => [
        DriverModel(
          id: 'driver_001',
          firstName: 'Michael',
          lastName: 'Chen',
          phoneNumber: '+14155559876',
          photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
          rating: 4.95,
          totalTrips: 2847,
          vehicle: const VehicleModel(
            id: 'vehicle_001',
            make: 'Toyota',
            model: 'Camry',
            year: 2022,
            color: 'Black',
            licensePlate: '7ABC123',
            type: VehicleType.economy,
          ),
        ),
        DriverModel(
          id: 'driver_002',
          firstName: 'Sarah',
          lastName: 'Williams',
          phoneNumber: '+14155558765',
          photoUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
          rating: 4.98,
          totalTrips: 1523,
          vehicle: const VehicleModel(
            id: 'vehicle_002',
            make: 'Mercedes',
            model: 'E-Class',
            year: 2023,
            color: 'Silver',
            licensePlate: '8XYZ789',
            type: VehicleType.premium,
          ),
        ),
        DriverModel(
          id: 'driver_003',
          firstName: 'James',
          lastName: 'Rodriguez',
          phoneNumber: '+14155557654',
          photoUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
          rating: 4.88,
          totalTrips: 3421,
          vehicle: const VehicleModel(
            id: 'vehicle_003',
            make: 'Chevrolet',
            model: 'Suburban',
            year: 2023,
            color: 'White',
            licensePlate: '5DEF456',
            type: VehicleType.xl,
          ),
        ),
      ];

  // Mock locations
  static LocationModel get userLocation => const LocationModel(
        latitude: 37.7749,
        longitude: -122.4194,
        address: '123 Market Street, San Francisco, CA 94103',
        name: 'Current Location',
      );

  static LocationModel get homeLocation => const LocationModel(
        latitude: 37.7849,
        longitude: -122.4094,
        address: '456 Valencia Street, San Francisco, CA 94110',
        name: 'Home',
      );

  static LocationModel get workLocation => const LocationModel(
        latitude: 37.7649,
        longitude: -122.4294,
        address: '789 Howard Street, San Francisco, CA 94103',
        name: 'Work',
      );

  static List<LocationModel> get popularDestinations => [
        const LocationModel(
          latitude: 37.7879,
          longitude: -122.4074,
          address: 'Union Square, San Francisco, CA',
          name: 'Union Square',
        ),
        const LocationModel(
          latitude: 37.8199,
          longitude: -122.4783,
          address: 'Golden Gate Bridge, San Francisco, CA',
          name: 'Golden Gate Bridge',
        ),
        const LocationModel(
          latitude: 37.7956,
          longitude: -122.3933,
          address: 'Ferry Building, San Francisco, CA',
          name: 'Ferry Building',
        ),
        const LocationModel(
          latitude: 37.7694,
          longitude: -122.4862,
          address: 'Golden Gate Park, San Francisco, CA',
          name: 'Golden Gate Park',
        ),
      ];

  static List<RecentPlace> get recentPlaces => [
        RecentPlace(
          id: 'recent_001',
          location: const LocationModel(
            latitude: 37.7879,
            longitude: -122.4074,
            address: '335 Powell Street, San Francisco, CA 94102',
            name: 'Union Square',
          ),
          visitedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        RecentPlace(
          id: 'recent_002',
          location: const LocationModel(
            latitude: 37.7694,
            longitude: -122.4862,
            address: '501 Stanyan Street, San Francisco, CA 94117',
            name: 'Golden Gate Park',
          ),
          visitedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        RecentPlace(
          id: 'recent_003',
          location: const LocationModel(
            latitude: 37.7956,
            longitude: -122.3933,
            address: '1 Ferry Building, San Francisco, CA 94111',
            name: 'Ferry Building Marketplace',
          ),
          visitedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

  static SavedPlace get savedHome => SavedPlace.home(location: homeLocation);
  static SavedPlace get savedWork => SavedPlace.work(location: workLocation);

  // Mock ride options
  static List<RideOptionModel> getRideOptions({
    required double distanceKm,
    required int durationMinutes,
  }) {
    final basePrice = 2.50 + (distanceKm * 1.75) + (durationMinutes * 0.35);
    return [
      RideOptionModel(
        type: RideType.economy,
        price: basePrice,
        etaMinutes: 3,
        durationMinutes: durationMinutes,
        distanceKm: distanceKm,
      ),
      RideOptionModel(
        type: RideType.premium,
        price: basePrice * 1.5,
        etaMinutes: 5,
        durationMinutes: durationMinutes,
        distanceKm: distanceKm,
      ),
      RideOptionModel(
        type: RideType.xl,
        price: basePrice * 1.3,
        etaMinutes: 7,
        durationMinutes: durationMinutes,
        distanceKm: distanceKm,
      ),
    ];
  }

  // Mock fare breakdown
  static FareBreakdown getFareBreakdown({
    required double distance,
    required int duration,
    required RideType type,
  }) {
    final baseFare = 2.50 * type.priceMultiplier;
    final distanceFare = distance * 1.75 * type.priceMultiplier;
    final timeFare = duration * 0.35 * type.priceMultiplier;
    final serviceFee = 2.75;
    final total = baseFare + distanceFare + timeFare + serviceFee;

    return FareBreakdown(
      baseFare: baseFare,
      distanceFare: distanceFare,
      timeFare: timeFare,
      serviceFee: serviceFee,
      total: total,
    );
  }

  // Mock ride history
  static List<RideModel> get rideHistory => [
        RideModel(
          id: 'ride_001',
          pickup: userLocation,
          destination: popularDestinations[0],
          rideType: RideType.economy,
          status: RideStatus.completed,
          driver: drivers[0],
          estimatedFare: 18.50,
          actualFare: 17.25,
          estimatedDurationMinutes: 15,
          estimatedDistanceKm: 4.2,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          pickupTime: DateTime.now().subtract(const Duration(days: 1, hours: 23, minutes: 45)),
          dropoffTime: DateTime.now().subtract(const Duration(days: 1, hours: 23, minutes: 30)),
          paymentMethod: PaymentMethod.card,
          rating: 5,
        ),
        RideModel(
          id: 'ride_002',
          pickup: homeLocation,
          destination: workLocation,
          rideType: RideType.premium,
          status: RideStatus.completed,
          driver: drivers[1],
          estimatedFare: 25.00,
          actualFare: 24.50,
          estimatedDurationMinutes: 20,
          estimatedDistanceKm: 5.5,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          pickupTime: DateTime.now().subtract(const Duration(days: 3, hours: 8, minutes: 15)),
          dropoffTime: DateTime.now().subtract(const Duration(days: 3, hours: 7, minutes: 55)),
          paymentMethod: PaymentMethod.card,
          rating: 5,
          tipAmount: 5.00,
        ),
      ];
}
