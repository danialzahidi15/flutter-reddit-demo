import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_danthocode_reddit/core/constants/firebase_constants.dart';
import 'package:flutter_danthocode_reddit/core/failure.dart';
import 'package:flutter_danthocode_reddit/core/providers/firebase_provider.dart';
import 'package:flutter_danthocode_reddit/models/community_model.dart';
import 'package:flutter_danthocode_reddit/models/post_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/type_defs.dart';

final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(
    firestore: ref.watch(firestoreProvider),
  );
});

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference get _communities => _firestore.collection(FirebaseConstants.communityCollection);
  CollectionReference get _posts => _firestore.collection(FirebaseConstants.postCollection);

  FutureVoid createCommunity(CommunityModel community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        throw 'Community already exists';
      }
      return right(_communities.doc(community.name).set(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid joinCommunity(String communityName, String userId) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayUnion([userId]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid leaveCommunity(String communityName, String userId) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayRemove([userId]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<CommunityModel>> getUserCommunity(String uid) {
    return _communities.where('members', arrayContains: uid).snapshots().map((event) {
      List<CommunityModel> communities = [];
      for (var doc in event.docs) {
        communities.add(CommunityModel.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  Stream<CommunityModel> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map(
          (event) => CommunityModel.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  FutureVoid editCommunity(CommunityModel community) async {
    try {
      return right(_communities.doc(community.name).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<CommunityModel>> searchCommunity(String query) {
    return _communities
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(
                    query.codeUnitAt(query.length - 1) + 1,
                  ),
        )
        .snapshots()
        .map(
      (event) {
        List<CommunityModel> communities = [];
        for (var community in event.docs) {
          communities.add(
            CommunityModel.fromMap(community.data() as Map<String, dynamic>),
          );
        }
        return communities;
      },
    );
  }

  FutureVoid addModerators(String communityName, List<String> uids) async {
    try {
      return right(_communities.doc(communityName).update({
        'mods': uids,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<PostModel>> getCommunityPosts(String name) {
    return _posts
        .where('communityName', isEqualTo: name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs.map((e) => PostModel.fromMap(e.data() as Map<String, dynamic>)).toList());
  }
}
