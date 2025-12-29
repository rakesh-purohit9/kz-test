import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../mock/mock_data.dart';

/// Ride booking flow state
enum RideFlowState {
  idle,
  selectingRide,
  searching,
  driverAssigned,
  driverArriving,
  driverArrived,
  inProgress,
  completed,
  cancelled,
}

class RideState {
  final RideFlowState flowState;
  final List<RideOptionModel> rideOptions;
  final RideType? selectedRideType;
  final RideModel? currentRide;
  final DriverModel? assignedDriver;
  final int? driverEta;
  final PaymentMethod paymentMethod;
  final bool isLoading;
  final String? error;
  final int? selectedTip;
  final int? rating;
  final String? feedback;
  final FareBreakdown? fareBreakdown;

  const RideState({
    this.flowState = RideFlowState.idle,
    this.rideOptions = const [],
    this.selectedRideType,
    this.currentRide,
    this.assignedDriver,
    this.driverEta,
    this.paymentMethod = PaymentMethod.card,
    this.isLoading = false,
    this.error,
    this.selectedTip,
    this.rating,
    this.feedback,
    this.fareBreakdown,
  });

  RideState copyWith({
    RideFlowState? flowState,
    List<RideOptionModel>? rideOptions,
    RideType? selectedRideType,
    RideModel? currentRide,
    DriverModel? assignedDriver,
    int? driverEta,
    PaymentMethod? paymentMethod,
    bool? isLoading,
    String? error,
    int? selectedTip,
    int? rating,
    String? feedback,
    FareBreakdown? fareBreakdown,
  }) {
    return RideState(
      flowState: flowState ?? this.flowState,
      rideOptions: rideOptions ?? this.rideOptions,
      selectedRideType: selectedRideType ?? this.selectedRideType,
      currentRide: currentRide ?? this.currentRide,
      assignedDriver: assignedDriver ?? this.assignedDriver,
      driverEta: driverEta ?? this.driverEta,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTip: selectedTip ?? this.selectedTip,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      fareBreakdown: fareBreakdown ?? this.fareBreakdown,
    );
  }

  bool get isActive =>
      flowState == RideFlowState.searching ||
      flowState == RideFlowState.driverAssigned ||
      flowState == RideFlowState.driverArriving ||
      flowState == RideFlowState.driverArrived ||
      flowState == RideFlowState.inProgress;

  RideOptionModel? get selectedOption {
    if (selectedRideType == null) return null;
    return rideOptions.firstWhere(
      (o) => o.type == selectedRideType,
      orElse: () => rideOptions.first,
    );
  }
}

class RideNotifier extends StateNotifier<RideState> {
  RideNotifier() : super(const RideState());

  Timer? _searchTimer;
  Timer? _etaTimer;
  Timer? _tripTimer;

  /// Get ride options for a route
  Future<void> getRideOptions({
    required LocationModel pickup,
    required LocationModel destination,
  }) async {
    state = state.copyWith(
      isLoading: true,
      flowState: RideFlowState.selectingRide,
    );

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    // Calculate distance (simplified)
    final distance = _calculateDistance(
      pickup.latitude,
      pickup.longitude,
      destination.latitude,
      destination.longitude,
    );
    final duration = (distance * 3).toInt(); // ~3 min per km

    final options = MockData.getRideOptions(
      distanceKm: distance,
      durationMinutes: duration,
    );

    state = state.copyWith(
      rideOptions: options,
      selectedRideType: RideType.economy,
      isLoading: false,
    );
  }

  /// Select ride type
  void selectRideType(RideType type) {
    state = state.copyWith(selectedRideType: type);
  }

  /// Set payment method
  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  /// Request ride
  Future<void> requestRide({
    required LocationModel pickup,
    required LocationModel destination,
  }) async {
    state = state.copyWith(
      flowState: RideFlowState.searching,
      isLoading: true,
    );

    // Simulate finding a driver (2-5 seconds)
    final searchDuration = 2000 + Random().nextInt(3000);

    _searchTimer = Timer(Duration(milliseconds: searchDuration), () {
      _assignDriver(pickup, destination);
    });
  }

  void _assignDriver(LocationModel pickup, LocationModel destination) {
    final selectedOption = state.selectedOption;
    if (selectedOption == null) return;

    // Select a random driver based on ride type
    final availableDrivers = MockData.drivers.where((d) {
      switch (selectedOption.type) {
        case RideType.economy:
          return d.vehicle.type == VehicleType.economy;
        case RideType.premium:
          return d.vehicle.type == VehicleType.premium;
        case RideType.xl:
          return d.vehicle.type == VehicleType.xl;
      }
    }).toList();

    final driver = availableDrivers.isNotEmpty
        ? availableDrivers[Random().nextInt(availableDrivers.length)]
        : MockData.drivers.first;

    final ride = RideModel(
      id: 'ride_${DateTime.now().millisecondsSinceEpoch}',
      pickup: pickup,
      destination: destination,
      rideType: selectedOption.type,
      status: RideStatus.accepted,
      driver: driver,
      estimatedFare: selectedOption.price,
      estimatedDurationMinutes: selectedOption.durationMinutes,
      estimatedDistanceKm: selectedOption.distanceKm,
      createdAt: DateTime.now(),
      paymentMethod: state.paymentMethod,
    );

    final initialEta = 3 + Random().nextInt(5); // 3-7 minutes

    state = state.copyWith(
      flowState: RideFlowState.driverAssigned,
      currentRide: ride,
      assignedDriver: driver,
      driverEta: initialEta,
      isLoading: false,
    );

    // Start ETA countdown
    _startEtaCountdown(initialEta);
  }

  void _startEtaCountdown(int initialEta) {
    var eta = initialEta;

    _etaTimer = Timer.periodic(const Duration(seconds: 3), (timer) {

      eta--;

      if (eta <= 1) {
        timer.cancel();
        state = state.copyWith(
          flowState: RideFlowState.driverArrived,
          driverEta: 0,
        );
      } else if (eta <= 2) {
        state = state.copyWith(
          flowState: RideFlowState.driverArriving,
          driverEta: eta,
        );
      } else {
        state = state.copyWith(driverEta: eta);
      }
    });
  }

  /// Start trip (when passenger is picked up)
  void startTrip() {
    if (state.currentRide == null) return;

    state = state.copyWith(
      flowState: RideFlowState.inProgress,
      currentRide: state.currentRide!.copyWith(
        status: RideStatus.inProgress,
        pickupTime: DateTime.now(),
      ),
    );

    // Simulate trip progress
    _startTripProgress();
  }

  void _startTripProgress() {
    var elapsed = 0;

    _tripTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      elapsed++;

      // Complete trip after 5 ticks for demo (10 seconds)
      if (elapsed >= 5) {
        timer.cancel();
        _completeTrip();
      }
    });
  }

  void _completeTrip() {
    if (state.currentRide == null) return;

    final fareBreakdown = MockData.getFareBreakdown(
      distance: state.currentRide!.estimatedDistanceKm,
      duration: state.currentRide!.estimatedDurationMinutes,
      type: state.currentRide!.rideType,
    );

    state = state.copyWith(
      flowState: RideFlowState.completed,
      currentRide: state.currentRide!.copyWith(
        status: RideStatus.completed,
        dropoffTime: DateTime.now(),
        actualFare: fareBreakdown.total,
      ),
      fareBreakdown: fareBreakdown,
    );
  }

  /// Select tip amount
  void selectTip(int? amount) {
    state = state.copyWith(selectedTip: amount);
  }

  /// Rate the ride
  void rateRide(int rating) {
    state = state.copyWith(rating: rating);
  }

  /// Submit feedback
  void submitFeedback(String feedback) {
    state = state.copyWith(feedback: feedback);
  }

  /// Complete rating and feedback
  Future<void> submitRating() async {
    if (state.currentRide == null) return;

    state = state.copyWith(isLoading: true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      currentRide: state.currentRide!.copyWith(
        rating: state.rating,
        tipAmount: state.selectedTip?.toDouble(),
        feedback: state.feedback,
      ),
      isLoading: false,
    );
  }

  /// Cancel ride
  Future<void> cancelRide() async {
    _searchTimer?.cancel();
    _etaTimer?.cancel();
    _tripTimer?.cancel();

    state = state.copyWith(
      flowState: RideFlowState.cancelled,
      isLoading: true,
    );

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      currentRide: state.currentRide?.copyWith(status: RideStatus.cancelled),
      isLoading: false,
    );
  }

  /// Reset state for new ride
  void reset() {
    _searchTimer?.cancel();
    _etaTimer?.cancel();
    _tripTimer?.cancel();

    state = const RideState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _etaTimer?.cancel();
    _tripTimer?.cancel();
    super.dispose();
  }
}

/// Ride provider
final rideProvider = StateNotifierProvider<RideNotifier, RideState>((ref) {
  return RideNotifier();
});

/// Ride history provider
final rideHistoryProvider = Provider<List<RideModel>>((ref) {
  return MockData.rideHistory;
});
