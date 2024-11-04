import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media/features/auth/domain/entities/app_user.dart';
import 'package:social_media/features/auth/domain/repos/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> getCurrentUser() async {
    User? user = firebaseAuth.currentUser;

    if (user == null) return null;

    // fetch user document from firestore
    DocumentSnapshot userDoc =
        await firebaseFirestore.collection("users").doc(user.uid).get();

    // Check if user doc exists
    if (!userDoc.exists) {
      return null;
    }

    return AppUser(
      uid: user.uid,
      email: user.email!,
      name: userDoc['name'],
    );
    //
  }

  @override
  Future<AppUser?> loginWittEmailPassword(String email, String password) async {
    try {
      // attemp sign in
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // fetch user document from firestore
      DocumentSnapshot userDoc = await firebaseFirestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      // create user
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email!,
        name: userDoc['name'],
      );

      return user;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  @override
  Future<AppUser?> registerWittEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      // attemp sign up
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // create user
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email!,
        name: name,
      );

      // save user data in firestore
      await firebaseFirestore
          .collection("users")
          .doc(user.uid)
          .set(user.toJson());

      return user;
    } catch (e) {
      throw Exception("Register failed: $e");
    }
  }

  @override
  Future<void> logout() async {
    return firebaseAuth.signOut();
  }
}
