import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../mock/mock_data.dart';

/// Location state
class LocationState {
  final LocationModel? currentLocation;
  final LocationModel? pickupLocation;
  final LocationModel? destinationLocation;
  final List<SavedPlace> savedPlaces;
  final List<RecentPlace> recentPlaces;
  final List<LocationModel> searchResults;
  final bool isLoading;
  final String? error;

  const LocationState({
    this.currentLocation,
    this.pickupLocation,
    this.destinationLocation,
    this.savedPlaces = const [],
    this.recentPlaces = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.error,
  });

  LocationState copyWith({
    LocationModel? currentLocation,
    LocationModel? pickupLocation,
    LocationModel? destinationLocation,
    List<SavedPlace>? savedPlaces,
    List<RecentPlace>? recentPlaces,
    List<LocationModel>? searchResults,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      savedPlaces: savedPlaces ?? this.savedPlaces,
      recentPlaces: recentPlaces ?? this.recentPlaces,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasRoute => pickupLocation != null && destinationLocation != null;
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState());

  /// Initialize location data
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    // Simulate getting current location
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      currentLocation: MockData.userLocation,
      pickupLocation: MockData.userLocation,
      savedPlaces: [MockData.savedHome, MockData.savedWork],
      recentPlaces: MockData.recentPlaces,
      isLoading: false,
    );
  }

  /// Update current location
  void updateCurrentLocation(LocationModel location) {
    state = state.copyWith(
      currentLocation: location,
      pickupLocation: location,
    );
  }

  /// Set pickup location
  void setPickupLocation(LocationModel location) {
    state = state.copyWith(pickupLocation: location);
  }

  /// Set destination location
  void setDestinationLocation(LocationModel location) {
    state = state.copyWith(destinationLocation: location);

    // Add to recent places
    final recentPlace = RecentPlace(
      id: 'recent_${DateTime.now().millisecondsSinceEpoch}',
      location: location,
      visitedAt: DateTime.now(),
    );

    final updatedRecent = [recentPlace, ...state.recentPlaces];
    if (updatedRecent.length > 10) {
      updatedRecent.removeLast();
    }

    state = state.copyWith(recentPlaces: updatedRecent);
  }

  /// Clear destination
  void clearDestination() {
    state = state.copyWith(
      destinationLocation: null,
      searchResults: [],
    );
  }

  /// Search for locations
  Future<void> searchLocations(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }

    state = state.copyWith(isLoading: true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));

    // Filter mock locations based on query
    final results = MockData.popularDestinations
        .where((loc) =>
            loc.name?.toLowerCase().contains(query.toLowerCase()) == true ||
            loc.address?.toLowerCase().contains(query.toLowerCase()) == true)
        .toList();

    // Add some mock search results
    if (results.isEmpty) {
      results.addAll([
        LocationModel(
          latitude: 37.7749 + (query.hashCode % 100) / 10000,
          longitude: -122.4194 + (query.hashCode % 50) / 10000,
          address: '$query Street, San Francisco, CA',
          name: query,
        ),
      ]);
    }

    state = state.copyWith(
      searchResults: results,
      isLoading: false,
    );
  }

  /// Clear search results
  void clearSearchResults() {
    state = state.copyWith(searchResults: []);
  }

  /// Update saved place
  void updateSavedPlace(SavedPlace place) {
    final updatedPlaces = state.savedPlaces.map((p) {
      if (p.id == place.id) {
        return place;
      }
      return p;
    }).toList();

    state = state.copyWith(savedPlaces: updatedPlaces);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Location provider
final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});
