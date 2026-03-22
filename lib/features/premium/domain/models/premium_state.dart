class PremiumState {
  PremiumState({
    this.isPremium = false,
    this.entitlementId,
  });

  factory PremiumState.initial() => PremiumState();
  final bool isPremium;
  final String? entitlementId;
}
