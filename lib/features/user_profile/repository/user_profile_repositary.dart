import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_danthocode_reddit/core/constants/firebase_constants.dart';
import 'package:flutter_danthocode_reddit/core/failure.dart';
import 'package:flutter_danthocode_reddit/core/providers/firebase_provider.dart';
import 'package:flutter_danthocode_reddit/core/type_defs.dart';
import 'package:flutter_danthocode_reddit/models/post_model.dart';
import 'package:flutter_danthocode_reddit/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final userProfileRepositoryProvider = Provider((ref) {
  final firestore = ref.watch(firestoreProvider);
  return UserProfileRepository(firestore: firestore);
});

class UserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _users => _firestore.collection(FirebaseConstants.userCollection);
  CollectionReference get _posts => _firestore.collection(FirebaseConstants.postCollection);

  FutureVoid editUser(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(user.toMap()));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<PostModel>> getUserPosts(String uid) {
    return _posts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs.map((e) => PostModel.fromMap(e.data() as Map<String, dynamic>)).toList());
  }

  FutureVoid updateUserKarma(UserModel userModel) async {
    try {
      return right(_users.doc(userModel.uid).update({
        'karma' : userModel.karma,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
