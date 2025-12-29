import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../mock/mock_data.dart';

/// Authentication state
enum AuthStatus {
  initial,
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? phoneNumber;
  final String? error;
  final bool isOtpSent;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.phoneNumber,
    this.error,
    this.isOtpSent = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? phoneNumber,
    String? error,
    bool? isOtpSent,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      error: error ?? this.error,
      isOtpSent: isOtpSent ?? this.isOtpSent,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.authenticating;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Check if user is already authenticated
  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.authenticating);

    // Simulate checking stored auth
    await Future.delayed(const Duration(milliseconds: 500));

    // For demo, start as unauthenticated
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  /// Send OTP to phone number
  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      phoneNumber: phoneNumber,
    );

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      isOtpSent: true,
    );
  }

  /// Verify OTP
  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(status: AuthStatus.authenticating);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // For demo, any 4-digit code works
    if (otp.length == 4) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: MockData.currentUser,
        isOtpSent: false,
      );
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: 'Invalid verification code',
      );
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset OTP state
  void resetOtpState() {
    state = state.copyWith(isOtpSent: false, phoneNumber: null);
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
