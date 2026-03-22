import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:feeltrip_app/features/auth/domain/entities/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_notifier.g.dart';

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Stream<AuthUser?> build() {
    return FirebaseAuth.instance.authStateChanges().map((user) {
      if (user == null) {
        return null;
      } else {
        return AuthUser(
          id: user.uid,
          email: user.email!,
          name: user.displayName,
          photoUrl: user.photoURL,
        );
      }
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
