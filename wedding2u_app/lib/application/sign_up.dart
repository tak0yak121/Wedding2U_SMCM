import 'package:wedding2u_app/data/firebase_auth_service.dart';
import 'package:wedding2u_app/data/firestore_service.dart';

class SignUpService {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> registerUser({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String role,
  }) async {
    // Authenticate the user and get UID
    String uid =
        await _authService.createUser(email: email, password: password);

    // Save user data to Firestore
    await _firestoreService.addUser(
      uid: uid,
      data: {
        'name': name,
        'phoneNumber': phoneNumber,
        'email': email,
        'role': role,
        'createdAt': DateTime.now(),
      },
    );
  }
}

// Patch change : Fix Create Account button tap issue during registration