class PremiumState {
  const PremiumState({
    this.isLoading = false,
    this.isPremium = false,
    this.error,
    this.activeEntitlements,
  });

  factory PremiumState.initial() => const PremiumState();
  final bool isLoading;
  final bool isPremium;
  final String? error;
  final List<String>? activeEntitlements;

  PremiumState copyWith({
    bool? isLoading,
    bool? isPremium,
    String? error,
    List<String>? activeEntitlements,
  }) {
    return PremiumState(
      isLoading: isLoading ?? this.isLoading,
      isPremium: isPremium ?? this.isPremium,
      error: error ?? this.error,
      activeEntitlements: activeEntitlements ?? this.activeEntitlements,
    );
  }
}
