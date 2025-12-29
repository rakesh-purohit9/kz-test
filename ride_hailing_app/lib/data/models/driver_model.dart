import 'package:equatable/equatable.dart';
import 'location_model.dart';

/// Model representing a driver
class DriverModel extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String photoUrl;
  final double rating;
  final int totalTrips;
  final VehicleModel vehicle;
  final LocationModel? currentLocation;

  const DriverModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.photoUrl,
    required this.rating,
    required this.totalTrips,
    required this.vehicle,
    this.currentLocation,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phoneNumber: json['phone_number'] as String,
      photoUrl: json['photo_url'] as String,
      rating: (json['rating'] as num).toDouble(),
      totalTrips: (json['total_trips'] as num).toInt(),
      vehicle: VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
      currentLocation: json['current_location'] != null
          ? LocationModel.fromJson(json['current_location'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'photo_url': photoUrl,
      'rating': rating,
      'total_trips': totalTrips,
      'vehicle': vehicle.toJson(),
      'current_location': currentLocation?.toJson(),
    };
  }

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
  String get ratingDisplay => rating.toStringAsFixed(1);

  DriverModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? photoUrl,
    double? rating,
    int? totalTrips,
    VehicleModel? vehicle,
    LocationModel? currentLocation,
  }) {
    return DriverModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      vehicle: vehicle ?? this.vehicle,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        phoneNumber,
        photoUrl,
        rating,
        totalTrips,
        vehicle,
        currentLocation,
      ];
}

/// Model representing a vehicle
class VehicleModel extends Equatable {
  final String id;
  final String make;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final VehicleType type;

  const VehicleModel({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    required this.type,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: (json['year'] as num).toInt(),
      color: json['color'] as String,
      licensePlate: json['license_plate'] as String,
      type: VehicleType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => VehicleType.economy,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'license_plate': licensePlate,
      'type': type.name,
    };
  }

  String get displayName => '$make $model';
  String get fullDescription => '$color $year $make $model';

  @override
  List<Object?> get props => [
        id,
        make,
        model,
        year,
        color,
        licensePlate,
        type,
      ];
}

enum VehicleType { economy, premium, xl }

extension VehicleTypeExtension on VehicleType {
  String get displayName {
    switch (this) {
      case VehicleType.economy:
        return 'Economy';
      case VehicleType.premium:
        return 'Premium';
      case VehicleType.xl:
        return 'XL';
    }
  }

  int get maxPassengers {
    switch (this) {
      case VehicleType.economy:
        return 4;
      case VehicleType.premium:
        return 4;
      case VehicleType.xl:
        return 6;
    }
  }
}
