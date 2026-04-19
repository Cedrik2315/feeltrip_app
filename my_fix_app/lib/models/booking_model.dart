import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/syncable_model.dart';

part 'booking_model.g.dart';

enum BookingStatus { pending, paid, confirmed, cancelled, failed }

@HiveType(typeId: 12)
class BookingModel extends HiveObject with SyncableModel {

  BookingModel({
    required this.id,
    required this.userId,
    required this.experienceId,
    this.preferenceId,
    this.paymentId,
    this.externalReference,
    this.status = BookingStatus.pending,
    this.provider = 'server_side',
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      experienceId: json['experienceId'] as String,
      preferenceId: json['preferenceId'] as String?,
      paymentId: json['paymentId'] as String?,
      externalReference: json['externalReference'] as String?,
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${json['status'] as String}',
        orElse: () => BookingStatus.pending,
      ),
      provider: json['provider'] as String? ?? 'server_side',
      amount: (json['amount'] as num).toDouble(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel.fromJson({
      ...data,
      'id': doc.id,
    });
  }
  @override
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String experienceId;

  @HiveField(3)
  final String? preferenceId;

  @HiveField(4)
  final String? paymentId;

  @HiveField(5)
  final String? externalReference;

  @HiveField(6)
  BookingStatus status;

  @HiveField(7)
  final String provider;

  @HiveField(8)
  final double amount;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  @override
  @HiveField(11)
  SyncStatus syncStatus = SyncStatus.local;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'experienceId': experienceId,
      'preferenceId': preferenceId,
      'paymentId': paymentId,
      'externalReference': externalReference,
      'status': status.name,
      'provider': provider,
      'amount': amount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'syncStatus': syncStatus.name,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      ...toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? userId,
    String? experienceId,
    String? preferenceId,
    String? paymentId,
    String? externalReference,
    BookingStatus? status,
    String? provider,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      experienceId: experienceId ?? this.experienceId,
      preferenceId: preferenceId ?? this.preferenceId,
      paymentId: paymentId ?? this.paymentId,
      externalReference: externalReference ?? this.externalReference,
      status: status ?? this.status,
      provider: provider ?? this.provider,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convenience getters for UI
  String get destinationId => experienceId;
  bool get isSynced => syncStatus == SyncStatus.synced;
  double get priceUsd => amount;
  String get currency => provider == 'revenue_cat' ? 'USD' : 'ARS';
}
