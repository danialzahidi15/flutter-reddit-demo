import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_danthocode_reddit/core/constants/asset_constants.dart';
import 'package:flutter_danthocode_reddit/core/constants/firebase_constants.dart';
import 'package:flutter_danthocode_reddit/core/failure.dart';
import 'package:flutter_danthocode_reddit/core/providers/firebase_provider.dart';
import 'package:flutter_danthocode_reddit/core/type_defs.dart';
import 'package:flutter_danthocode_reddit/models/user_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod/riverpod.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(firebaseAuthProvider),
    googleSignIn: ref.read(googleSignInProvider),
  );
});

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users => _firestore.collection(FirebaseConstants.userCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signinWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      late UserModel userModel;

      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          name: userCredential.user!.displayName ?? 'No Name',
          profilePic: userCredential.user!.photoURL ?? AssetConstants.avatarDefault,
          banner: AssetConstants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: true,
          karma: 0,
          awards: [
            'awesomeAnswer',
            'gold',
            'helpful',
            'platinum',
            'plusone',
            'rocket',
            'thankyou',
            'til',
          ],
        );
        await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
          (event) => UserModel.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  FutureEither<UserModel> signinAnonymously() async {
    try {
      var userCredential = await _auth.signInAnonymously();
      var guestNumber = '';
      var random = Random();

      for (var i = 0; i < 8; i++) {
        guestNumber = guestNumber + random.nextInt(9).toString();
      }

      UserModel userModel = UserModel(
        name: 'Guest$guestNumber',
        profilePic: AssetConstants.avatarDefault,
        banner: AssetConstants.bannerDefault,
        uid: userCredential.user!.uid,
        isAuthenticated: false,
        karma: 0,
        awards: [],
      );

      await _users.doc(userCredential.user!.uid).set(userModel.toMap());

      return right(userModel);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
