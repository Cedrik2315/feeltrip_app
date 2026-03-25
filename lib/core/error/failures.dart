import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

class AuthFailure extends Failure {
  const AuthFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
