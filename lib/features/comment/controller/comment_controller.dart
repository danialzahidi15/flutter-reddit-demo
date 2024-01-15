import 'package:flutter/cupertino.dart';
import 'package:flutter_danthocode_reddit/core/enum/enum.dart';
import 'package:flutter_danthocode_reddit/core/utils.dart';
import 'package:flutter_danthocode_reddit/features/auth/controller/auth_controller.dart';
import 'package:flutter_danthocode_reddit/features/comment/repository/comment_repository.dart';
import 'package:flutter_danthocode_reddit/features/user_profile/controller/user_profile_controller.dart';
import 'package:flutter_danthocode_reddit/models/comment_model.dart';
import 'package:flutter_danthocode_reddit/models/post_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final commentControllerProvider = StateNotifierProvider<CommentController, bool>((ref) {
  final commentRepository = ref.watch(commentRepositoryProvider);
  return CommentController(commentRepository: commentRepository, ref: ref);
});

final getAllCommentOfPostProvider = StreamProvider.family((ref, String postId) {
  final commentController = ref.watch(commentControllerProvider.notifier);
  return commentController.getAllCommentsOfPost(postId);
});

class CommentController extends StateNotifier<bool> {
  final CommentRepository _commentRepository;
  final Ref _ref;
  CommentController({required CommentRepository commentRepository, required Ref ref})
      : _commentRepository = commentRepository,
        _ref = ref,
        super(false);

  void postComment({
    required BuildContext context,
    required String text,
    required PostModel postModel,
  }) async {
    final user = _ref.read(userProvider)!;
    String commentId = const Uuid().v1();

    CommentModel commentModel = CommentModel(
      id: commentId,
      text: text,
      createdAt: DateTime.now(),
      postId: postModel.postId,
      username: user.name,
      profilePic: user.profilePic,
    );

    final res = await _commentRepository.postComment(commentModel);
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.comment);
    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) => null,
    );
  }

  Stream<List<CommentModel>> getAllCommentsOfPost(String postId) {
    return _commentRepository.getAllCommentsOfPosts(postId);
  }
}
