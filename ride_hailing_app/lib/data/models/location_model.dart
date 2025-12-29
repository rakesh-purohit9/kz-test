import 'package:equatable/equatable.dart';

/// Model representing a geographic location
class LocationModel extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;
  final String? name;
  final String? placeId;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    this.address,
    this.name,
    this.placeId,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      name: json['name'] as String?,
      placeId: json['place_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'name': name,
      'place_id': placeId,
    };
  }

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? name,
    String? placeId,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      name: name ?? this.name,
      placeId: placeId ?? this.placeId,
    );
  }

  String get displayName => name ?? address ?? '$latitude, $longitude';
  String get shortAddress {
    if (address == null) return displayName;
    final parts = address!.split(',');
    return parts.isNotEmpty ? parts.first.trim() : address!;
  }

  @override
  List<Object?> get props => [latitude, longitude, address, name, placeId];
}

/// Model for saved places (Home, Work, etc.)
class SavedPlace extends Equatable {
  final String id;
  final String name;
  final String icon;
  final LocationModel? location;
  final SavedPlaceType type;

  const SavedPlace({
    required this.id,
    required this.name,
    required this.icon,
    this.location,
    required this.type,
  });

  factory SavedPlace.home({LocationModel? location}) {
    return SavedPlace(
      id: 'home',
      name: 'Home',
      icon: 'home',
      location: location,
      type: SavedPlaceType.home,
    );
  }

  factory SavedPlace.work({LocationModel? location}) {
    return SavedPlace(
      id: 'work',
      name: 'Work',
      icon: 'work',
      location: location,
      type: SavedPlaceType.work,
    );
  }

  bool get isSet => location != null;

  SavedPlace copyWith({
    String? id,
    String? name,
    String? icon,
    LocationModel? location,
    SavedPlaceType? type,
  }) {
    return SavedPlace(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      location: location ?? this.location,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, location, type];
}

enum SavedPlaceType { home, work, other }

/// Model for recent places
class RecentPlace extends Equatable {
  final String id;
  final LocationModel location;
  final DateTime visitedAt;

  const RecentPlace({
    required this.id,
    required this.location,
    required this.visitedAt,
  });

  factory RecentPlace.fromJson(Map<String, dynamic> json) {
    return RecentPlace(
      id: json['id'] as String,
      location: LocationModel.fromJson(json['location'] as Map<String, dynamic>),
      visitedAt: DateTime.parse(json['visited_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location.toJson(),
      'visited_at': visitedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, location, visitedAt];
}
