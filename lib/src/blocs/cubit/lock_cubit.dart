import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_lock/src/entities/authenticator.dart';
import 'package:pin_lock/src/entities/failure.dart';
import 'package:pin_lock/src/entities/value_objects.dart';

class LockCubit extends Cubit<LockScreenState> {
  final Authenticator _authenticator;
  Timer? _lockoutTimer;
  LockCubit(this._authenticator)
      : super(const LockScreenState(isLoading: true));

  Future<void> initialize() async {
    final blockedDuration =
        await _authenticator.getAuthenticationBlockDuration();
    if (blockedDuration != null) {
      _startLockout(blockedDuration);
      return;
    }
    emit(const LockScreenState());
  }

  Future<void> enterPin(String pin) async {
    if (!state.isPinInputEnabled) {
      return;
    }
    emit(LockScreenState(pin: pin));
    if (_authenticator.pinLength == pin.length) {
      final result = await _authenticator.unlockWithPin(pin: Pin(pin));
      result.fold(
        (l) {
          if (l == LocalAuthFailure.tooManyAttempts) {
            _handleLockout();
          } else {
            emit(LockScreenState(error: l));
          }
        },
        (r) => null,
      );
    }
  }

  Future<void> unlockWithBiometrics(String userFacingExplanation) async {
    final result = await _authenticator.unlockWithBiometrics(
      userFacingExplanation: userFacingExplanation,
    );
    result.fold(
      (l) {
        if (l == LocalAuthFailure.tooManyAttempts) {
          _handleLockout();
        } else {
          emit(LockScreenState(pin: state.pin, error: l));
        }
      },
      (r) => null,
    );
  }

  Future<void> _handleLockout() async {
    final duration = await _authenticator.getAuthenticationBlockDuration();
    if (duration != null) {
      _startLockout(duration);
    }
  }

  void _startLockout(Duration duration) {
    _lockoutTimer?.cancel();
    emit(
      LockScreenState(
        isPinInputEnabled: false,
        authenticationBlockedFor: duration,
        error: LocalAuthFailure.tooManyAttempts,
      ),
    );
    _lockoutTimer = Timer(duration, () {
      emit(const LockScreenState());
    });
  }

  @override
  Future<void> close() {
    _lockoutTimer?.cancel();
    return super.close();
  }
}

class LockScreenState extends Equatable {
  final bool isLoading;
  final String pin;
  final LocalAuthFailure? error;
  final bool isPinInputEnabled;
  final Duration? authenticationBlockedFor;

  const LockScreenState({
    this.isLoading = false,
    this.pin = '',
    this.error,
    this.isPinInputEnabled = true,
    this.authenticationBlockedFor,
  });

  @override
  List<Object?> get props => [
        isLoading,
        pin,
        error,
        isPinInputEnabled,
        authenticationBlockedFor,
      ];
}
