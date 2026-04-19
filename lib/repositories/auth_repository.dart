import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository(ref.watch(userRepositoryProvider)));

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class AuthRepository {
  final UserRepository _userRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthRepository(this._userRepository);

  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    await _userRepository.saveUser(credential.user!);
    return credential;
  }

  Future<UserCredential> createUserWithEmailAndPassword({required String email, required String password}) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await _userRepository.saveUser(credential.user!);
    return credential;
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await GoogleSignIn.instance.authenticate();
    final idToken = googleUser.authentication.idToken;

    final credential = GoogleAuthProvider.credential(idToken: idToken);

    final userCredential = await _auth.signInWithCredential(credential);
    await _userRepository.saveUser(userCredential.user!);

    return userCredential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn.instance.signOut();
  }
}
