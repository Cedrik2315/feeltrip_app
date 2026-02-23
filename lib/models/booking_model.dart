class Booking {
  final String id;
  final String userId;
  final String tripId;
  final String tripTitle;
  final int numberOfPeople;
  final double totalPrice;
  final String status;
  final DateTime bookingDate;
  final DateTime startDate;
  final List<String> passengers;
  final String paymentMethod;
  final bool isPaid;

  Booking({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.tripTitle,
    required this.numberOfPeople,
    required this.totalPrice,
    this.status = 'Confirmada',
    required this.bookingDate,
    required this.startDate,
    this.passengers = const [],
    this.paymentMethod = 'Tarjeta de Crédito',
    this.isPaid = false,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      tripId: json['tripId'] ?? '',
      tripTitle: json['tripTitle'] ?? '',
      numberOfPeople: json['numberOfPeople'] ?? 1,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'Confirmada',
      bookingDate: json['bookingDate'] != null
          ? DateTime.parse(json['bookingDate'])
          : DateTime.now(),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      passengers: List<String>.from(json['passengers'] ?? []),
      paymentMethod: json['paymentMethod'] ?? 'Tarjeta de Crédito',
      isPaid: json['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tripId': tripId,
      'tripTitle': tripTitle,
      'numberOfPeople': numberOfPeople,
      'totalPrice': totalPrice,
      'status': status,
      'bookingDate': bookingDate.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'passengers': passengers,
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
    };
  }
}
