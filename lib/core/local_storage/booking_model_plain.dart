import 'package:isar/isar.dart';

part 'booking_model_plain.g.dart';

@collection
class BookingModelPlain {
  Id id = Isar.autoIncrement;

  @Index()
  late String firestoreId;

  late String userId;
  late String destinationId;
  late String tripDates;
  late double priceUsd;
  late String currency;
  late String status;
  late double commission;
  bool isSynced = false;
}
