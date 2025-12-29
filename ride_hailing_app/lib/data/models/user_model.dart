import 'package:equatable/equatable.dart';

/// User model representing the rider
class UserModel extends Equatable {
  final String id;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? photoUrl;
  final double rating;
  final int totalTrips;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.email,
    this.photoUrl,
    this.rating = 5.0,
    this.totalTrips = 0,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      email: json['email'] as String?,
      photoUrl: json['photo_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalTrips: (json['total_trips'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'photo_url': photoUrl,
      'rating': rating,
      'total_trips': totalTrips,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get fullName {
    if (firstName == null && lastName == null) {
      return 'Rider';
    }
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  String get initials {
    final first = firstName?.isNotEmpty == true ? firstName![0] : '';
    final last = lastName?.isNotEmpty == true ? lastName![0] : '';
    if (first.isEmpty && last.isEmpty) return 'R';
    return '$first$last'.toUpperCase();
  }

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? email,
    String? photoUrl,
    double? rating,
    int? totalTrips,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        firstName,
        lastName,
        email,
        photoUrl,
        rating,
        totalTrips,
        createdAt,
      ];
}
