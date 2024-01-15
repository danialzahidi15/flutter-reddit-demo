import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_danthocode_reddit/core/constants/firebase_constants.dart';
import 'package:flutter_danthocode_reddit/core/failure.dart';
import 'package:flutter_danthocode_reddit/core/providers/firebase_provider.dart';
import 'package:flutter_danthocode_reddit/core/type_defs.dart';
import 'package:flutter_danthocode_reddit/models/community_model.dart';
import 'package:flutter_danthocode_reddit/models/post_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final postRepositoryProvider = Provider((ref) {
  final firestore = ref.watch(firestoreProvider);
  return PostRepository(firestore: firestore);
});

class PostRepository {
  final FirebaseFirestore _firestore;
  PostRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _posts => _firestore.collection(FirebaseConstants.postCollection);
  CollectionReference get _users => _firestore.collection(FirebaseConstants.userCollection);

  FutureVoid addPost(PostModel postModel) async {
    try {
      return right(_posts.doc(postModel.postId).set(postModel.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<PostModel>> fetchUserPosts(List<CommunityModel> communities) {
    return _posts
        .where(
          'communityName',
          whereIn: communities.map((e) => e.name),
        )
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => PostModel.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }

  FutureVoid deletePost(PostModel postModel) async {
    try {
      return right(_posts.doc(postModel.postId).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  void upvote(PostModel postModel, String userId) async {
    if (postModel.downvotes.contains(userId)) {
      _posts.doc(postModel.postId).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    }

    if (postModel.upvotes.contains(userId)) {
      _posts.doc(postModel.postId).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _posts.doc(postModel.postId).update({
        'upvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  void downVote(PostModel postModel, String userId) async {
    if (postModel.upvotes.contains(userId)) {
      _posts.doc(postModel.postId).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    }

    if (postModel.downvotes.contains(userId)) {
      _posts.doc(postModel.postId).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _posts.doc(postModel.postId).update({
        'downvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Stream<PostModel> getPostById(String postId) {
    return _posts.doc(postId).snapshots().map(
          (event) => PostModel.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  FutureVoid awardPost(PostModel postModel, String award, String senderId) async {
    try {
      _posts.doc(postModel.postId).update({
        'awards': FieldValue.arrayUnion([award]),
      });
      _users.doc(senderId).update({
        'awards': FieldValue.arrayRemove([award]),
      });
      return right(_users.doc(postModel.uid).update({
        'award': FieldValue.arrayUnion([award]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
