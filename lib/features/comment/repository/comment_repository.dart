import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_danthocode_reddit/core/constants/firebase_constants.dart';
import 'package:flutter_danthocode_reddit/core/failure.dart';
import 'package:flutter_danthocode_reddit/core/providers/firebase_provider.dart';
import 'package:flutter_danthocode_reddit/core/type_defs.dart';
import 'package:flutter_danthocode_reddit/models/comment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final commentRepositoryProvider = Provider((ref) {
  final firebaseFirestore = ref.watch(firestoreProvider);
  return CommentRepository(firebaseFirestore: firebaseFirestore);
});

class CommentRepository {
  final FirebaseFirestore _firebaseFirestore;
  CommentRepository({required FirebaseFirestore firebaseFirestore}) : _firebaseFirestore = firebaseFirestore;

  CollectionReference get _comments => _firebaseFirestore.collection(FirebaseConstants.commentCollection);
  CollectionReference get _posts => _firebaseFirestore.collection(FirebaseConstants.postCollection);

  FutureVoid postComment(CommentModel commentModel) async {
    try {
      await _comments.doc(commentModel.id).set(commentModel.toMap());
      
      return right(_posts.doc(commentModel.postId).update({
        'commentCount': FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<CommentModel>> getAllCommentsOfPosts(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs.map((e) => CommentModel.fromMap(e.data() as Map<String, dynamic>)).toList());
  }
}
