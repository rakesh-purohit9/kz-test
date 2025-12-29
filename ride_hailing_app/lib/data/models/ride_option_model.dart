import 'package:equatable/equatable.dart';
import 'ride_model.dart';

/// Model representing a ride option (for selection)
class RideOptionModel extends Equatable {
  final RideType type;
  final double price;
  final int etaMinutes;
  final int durationMinutes;
  final double distanceKm;
  final bool isAvailable;
  final String? surgeMultiplier;

  const RideOptionModel({
    required this.type,
    required this.price,
    required this.etaMinutes,
    required this.durationMinutes,
    required this.distanceKm,
    this.isAvailable = true,
    this.surgeMultiplier,
  });

  factory RideOptionModel.fromJson(Map<String, dynamic> json) {
    return RideOptionModel(
      type: RideType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => RideType.economy,
      ),
      price: (json['price'] as num).toDouble(),
      etaMinutes: (json['eta_minutes'] as num).toInt(),
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      isAvailable: json['is_available'] as bool? ?? true,
      surgeMultiplier: json['surge_multiplier'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'price': price,
      'eta_minutes': etaMinutes,
      'duration_minutes': durationMinutes,
      'distance_km': distanceKm,
      'is_available': isAvailable,
      'surge_multiplier': surgeMultiplier,
    };
  }

  String get priceDisplay => '\$${price.toStringAsFixed(2)}';
  String get etaDisplay => '$etaMinutes min';
  String get durationDisplay => '$durationMinutes min';
  String get distanceDisplay => '${distanceKm.toStringAsFixed(1)} mi';

  bool get hasSurge => surgeMultiplier != null;

  RideOptionModel copyWith({
    RideType? type,
    double? price,
    int? etaMinutes,
    int? durationMinutes,
    double? distanceKm,
    bool? isAvailable,
    String? surgeMultiplier,
  }) {
    return RideOptionModel(
      type: type ?? this.type,
      price: price ?? this.price,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      isAvailable: isAvailable ?? this.isAvailable,
      surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
    );
  }

  @override
  List<Object?> get props => [
        type,
        price,
        etaMinutes,
        durationMinutes,
        distanceKm,
        isAvailable,
        surgeMultiplier,
      ];
}

/// Fare breakdown model
class FareBreakdown extends Equatable {
  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double serviceFee;
  final double? surgeAmount;
  final double? discount;
  final double total;

  const FareBreakdown({
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.serviceFee,
    this.surgeAmount,
    this.discount,
    required this.total,
  });

  factory FareBreakdown.fromJson(Map<String, dynamic> json) {
    return FareBreakdown(
      baseFare: (json['base_fare'] as num).toDouble(),
      distanceFare: (json['distance_fare'] as num).toDouble(),
      timeFare: (json['time_fare'] as num).toDouble(),
      serviceFee: (json['service_fee'] as num).toDouble(),
      surgeAmount: (json['surge_amount'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_fare': baseFare,
      'distance_fare': distanceFare,
      'time_fare': timeFare,
      'service_fee': serviceFee,
      'surge_amount': surgeAmount,
      'discount': discount,
      'total': total,
    };
  }

  String formatAmount(double amount) => '\$${amount.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
        baseFare,
        distanceFare,
        timeFare,
        serviceFee,
        surgeAmount,
        discount,
        total,
      ];
}
