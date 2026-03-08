import 'app_error.dart';

class ErrorPresenter {
  static String message(Object error) {
    return AppException.from(error).message;
  }

  static bool retryable(Object error) {
    return AppException.from(error).retryable;
  }
}

