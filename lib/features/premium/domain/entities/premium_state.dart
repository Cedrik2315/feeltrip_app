import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

part 'premium_state.freezed.dart';
part 'premium_state.g.dart';

@freezed
class PremiumState with _$PremiumState {
  const factory PremiumState({
    @Default(false) bool isPremium,
    @Default([]) List<Offering> offerings,
    @Default(null) Package? activePackage,
    String? errorMessage,
  }) = _PremiumState;

  factory PremiumState.fromJson(Map<String, dynamic> json) => _$PremiumStateFromJson(json);
}
