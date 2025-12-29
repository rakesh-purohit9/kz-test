import 'package:equatable/equatable.dart';
import 'driver_model.dart';
import 'location_model.dart';

/// Model representing a ride request/trip
class RideModel extends Equatable {
  final String id;
  final LocationModel pickup;
  final LocationModel destination;
  final RideType rideType;
  final RideStatus status;
  final DriverModel? driver;
  final double estimatedFare;
  final double? actualFare;
  final int estimatedDurationMinutes;
  final double estimatedDistanceKm;
  final DateTime createdAt;
  final DateTime? pickupTime;
  final DateTime? dropoffTime;
  final PaymentMethod paymentMethod;
  final int? rating;
  final double? tipAmount;
  final String? feedback;
  final List<LocationModel>? routePoints;

  const RideModel({
    required this.id,
    required this.pickup,
    required this.destination,
    required this.rideType,
    required this.status,
    this.driver,
    required this.estimatedFare,
    this.actualFare,
    required this.estimatedDurationMinutes,
    required this.estimatedDistanceKm,
    required this.createdAt,
    this.pickupTime,
    this.dropoffTime,
    required this.paymentMethod,
    this.rating,
    this.tipAmount,
    this.feedback,
    this.routePoints,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] as String,
      pickup: LocationModel.fromJson(json['pickup'] as Map<String, dynamic>),
      destination: LocationModel.fromJson(json['destination'] as Map<String, dynamic>),
      rideType: RideType.values.firstWhere(
        (t) => t.name == json['ride_type'],
        orElse: () => RideType.economy,
      ),
      status: RideStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => RideStatus.requested,
      ),
      driver: json['driver'] != null
          ? DriverModel.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      estimatedFare: (json['estimated_fare'] as num).toDouble(),
      actualFare: (json['actual_fare'] as num?)?.toDouble(),
      estimatedDurationMinutes: (json['estimated_duration_minutes'] as num).toInt(),
      estimatedDistanceKm: (json['estimated_distance_km'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      pickupTime: json['pickup_time'] != null
          ? DateTime.parse(json['pickup_time'] as String)
          : null,
      dropoffTime: json['dropoff_time'] != null
          ? DateTime.parse(json['dropoff_time'] as String)
          : null,
      paymentMethod: PaymentMethod.values.firstWhere(
        (p) => p.name == json['payment_method'],
        orElse: () => PaymentMethod.card,
      ),
      rating: (json['rating'] as num?)?.toInt(),
      tipAmount: (json['tip_amount'] as num?)?.toDouble(),
      feedback: json['feedback'] as String?,
      routePoints: (json['route_points'] as List<dynamic>?)
          ?.map((p) => LocationModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pickup': pickup.toJson(),
      'destination': destination.toJson(),
      'ride_type': rideType.name,
      'status': status.name,
      'driver': driver?.toJson(),
      'estimated_fare': estimatedFare,
      'actual_fare': actualFare,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'estimated_distance_km': estimatedDistanceKm,
      'created_at': createdAt.toIso8601String(),
      'pickup_time': pickupTime?.toIso8601String(),
      'dropoff_time': dropoffTime?.toIso8601String(),
      'payment_method': paymentMethod.name,
      'rating': rating,
      'tip_amount': tipAmount,
      'feedback': feedback,
      'route_points': routePoints?.map((p) => p.toJson()).toList(),
    };
  }

  String get fareDisplay => '\$${estimatedFare.toStringAsFixed(2)}';
  String get actualFareDisplay => actualFare != null
      ? '\$${actualFare!.toStringAsFixed(2)}'
      : fareDisplay;
  String get durationDisplay => '$estimatedDurationMinutes min';
  String get distanceDisplay => '${estimatedDistanceKm.toStringAsFixed(1)} mi';

  double get totalFare {
    final base = actualFare ?? estimatedFare;
    return base + (tipAmount ?? 0);
  }

  bool get isActive =>
      status == RideStatus.requested ||
      status == RideStatus.accepted ||
      status == RideStatus.arriving ||
      status == RideStatus.arrived ||
      status == RideStatus.inProgress;

  bool get isCompleted =>
      status == RideStatus.completed || status == RideStatus.cancelled;

  RideModel copyWith({
    String? id,
    LocationModel? pickup,
    LocationModel? destination,
    RideType? rideType,
    RideStatus? status,
    DriverModel? driver,
    double? estimatedFare,
    double? actualFare,
    int? estimatedDurationMinutes,
    double? estimatedDistanceKm,
    DateTime? createdAt,
    DateTime? pickupTime,
    DateTime? dropoffTime,
    PaymentMethod? paymentMethod,
    int? rating,
    double? tipAmount,
    String? feedback,
    List<LocationModel>? routePoints,
  }) {
    return RideModel(
      id: id ?? this.id,
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      rideType: rideType ?? this.rideType,
      status: status ?? this.status,
      driver: driver ?? this.driver,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      actualFare: actualFare ?? this.actualFare,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      estimatedDistanceKm: estimatedDistanceKm ?? this.estimatedDistanceKm,
      createdAt: createdAt ?? this.createdAt,
      pickupTime: pickupTime ?? this.pickupTime,
      dropoffTime: dropoffTime ?? this.dropoffTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      rating: rating ?? this.rating,
      tipAmount: tipAmount ?? this.tipAmount,
      feedback: feedback ?? this.feedback,
      routePoints: routePoints ?? this.routePoints,
    );
  }

  @override
  List<Object?> get props => [
        id,
        pickup,
        destination,
        rideType,
        status,
        driver,
        estimatedFare,
        actualFare,
        estimatedDurationMinutes,
        estimatedDistanceKm,
        createdAt,
        pickupTime,
        dropoffTime,
        paymentMethod,
        rating,
        tipAmount,
        feedback,
        routePoints,
      ];
}

/// Ride status enum
enum RideStatus {
  requested,    // Rider requested, finding driver
  accepted,     // Driver accepted, on the way to pickup
  arriving,     // Driver almost at pickup
  arrived,      // Driver at pickup location
  inProgress,   // Trip in progress
  completed,    // Trip completed
  cancelled,    // Trip cancelled
}

extension RideStatusExtension on RideStatus {
  String get displayName {
    switch (this) {
      case RideStatus.requested:
        return 'Finding your ride';
      case RideStatus.accepted:
        return 'Driver on the way';
      case RideStatus.arriving:
        return 'Driver is arriving';
      case RideStatus.arrived:
        return 'Driver has arrived';
      case RideStatus.inProgress:
        return 'Trip in progress';
      case RideStatus.completed:
        return 'Trip completed';
      case RideStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get canCancel {
    return this == RideStatus.requested ||
        this == RideStatus.accepted ||
        this == RideStatus.arriving;
  }
}

/// Ride type enum
enum RideType {
  economy,
  premium,
  xl,
}

extension RideTypeExtension on RideType {
  String get displayName {
    switch (this) {
      case RideType.economy:
        return 'Economy';
      case RideType.premium:
        return 'Premium';
      case RideType.xl:
        return 'XL';
    }
  }

  String get description {
    switch (this) {
      case RideType.economy:
        return 'Affordable rides';
      case RideType.premium:
        return 'High-end cars';
      case RideType.xl:
        return 'Spacious vehicles';
    }
  }

  String get iconAsset {
    switch (this) {
      case RideType.economy:
        return 'assets/icons/car_economy.svg';
      case RideType.premium:
        return 'assets/icons/car_premium.svg';
      case RideType.xl:
        return 'assets/icons/car_xl.svg';
    }
  }

  int get seats {
    switch (this) {
      case RideType.economy:
        return 4;
      case RideType.premium:
        return 4;
      case RideType.xl:
        return 6;
    }
  }

  double get priceMultiplier {
    switch (this) {
      case RideType.economy:
        return 1.0;
      case RideType.premium:
        return 1.5;
      case RideType.xl:
        return 1.3;
    }
  }
}

/// Payment method enum
enum PaymentMethod {
  card,
  cash,
  wallet,
  applePay,
  googlePay,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.applePay:
        return 'Apple Pay';
      case PaymentMethod.googlePay:
        return 'Google Pay';
    }
  }

  String get iconAsset {
    switch (this) {
      case PaymentMethod.card:
        return 'assets/icons/card.svg';
      case PaymentMethod.cash:
        return 'assets/icons/cash.svg';
      case PaymentMethod.wallet:
        return 'assets/icons/wallet.svg';
      case PaymentMethod.applePay:
        return 'assets/icons/apple_pay.svg';
      case PaymentMethod.googlePay:
        return 'assets/icons/google_pay.svg';
    }
  }
}
