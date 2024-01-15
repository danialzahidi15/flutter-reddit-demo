import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_danthocode_reddit/core/enum/enum.dart';
import 'package:flutter_danthocode_reddit/core/providers/firebase_storage_provider.dart';
import 'package:flutter_danthocode_reddit/core/utils.dart';
import 'package:flutter_danthocode_reddit/features/auth/controller/auth_controller.dart';
import 'package:flutter_danthocode_reddit/features/post/repository/post_repository.dart';
import 'package:flutter_danthocode_reddit/features/user_profile/controller/user_profile_controller.dart';
import 'package:flutter_danthocode_reddit/models/community_model.dart';
import 'package:flutter_danthocode_reddit/models/post_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final postControllerProvider = StateNotifierProvider<PostController, bool>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(
    postRepository: postRepository,
    ref: ref,
    storageRepository: storageRepository,
  );
});

final fetchUserPostsProvider = StreamProvider.family((ref, List<CommunityModel> communities) {
  return ref.watch(postControllerProvider.notifier).fetchUserPosts(communities);
});

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.read(postControllerProvider.notifier);
  return postController.getPostById(postId);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  PostController({
    required PostRepository postRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void postText({
    required BuildContext context,
    required String title,
    required String description,
    required CommunityModel selectedCommunity,
  }) async {
    state = true;
    final postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    PostModel postModel = PostModel(
      postId: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: user.profilePic,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'text',
      createdAt: DateTime.now(),
      awards: [],
      description: description,
    );

    final res = await _postRepository.addPost(postModel);
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.textPost);

    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) {
      showSnackbar(context, 'Post Successfully');
      Routemaster.of(context).pop();
    });
  }

  void postLink({
    required BuildContext context,
    required String title,
    required String link,
    required CommunityModel selectedCommunity,
  }) async {
    state = true;
    final postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    PostModel postModel = PostModel(
      postId: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: user.profilePic,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.name,
      uid: user.uid,
      type: 'link',
      createdAt: DateTime.now(),
      awards: [],
      link: link,
    );

    final res = await _postRepository.addPost(postModel);
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.linkPost);

    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) {
      showSnackbar(context, 'Post Successfully');
      Routemaster.of(context).pop();
    });
  }

  void postImage({
    required BuildContext context,
    required String title,
    required CommunityModel selectedCommunity,
    required File? file,
  }) async {
    state = true;
    final postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final imageRes = await _storageRepository.uploadImage(
      path: 'posts/${selectedCommunity.name}',
      id: postId,
      file: file,
    );

    imageRes.fold((l) => showSnackbar(context, l.message), (r) async {
      PostModel postModel = PostModel(
        postId: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: user.profilePic,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'image',
        createdAt: DateTime.now(),
        awards: [],
        link: r,
      );

      final res = await _postRepository.addPost(postModel);
      _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.imagePost);

      state = false;
      res.fold((l) => showSnackbar(context, l.message), (r) {
        showSnackbar(context, 'Post Successfully');
        Routemaster.of(context).pop();
      });
    });
  }

  Stream<List<PostModel>> fetchUserPosts(List<CommunityModel> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }

  void deletePost(BuildContext context, PostModel postModel) async {
    final res = await _postRepository.deletePost(postModel);
    _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.deletePost);

    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) => showSnackbar(context, 'Post successfully deleted'),
    );
  }

  void upvotePost(PostModel postModel) async {
    final user = _ref.read(userProvider)!;
    _postRepository.upvote(postModel, user.uid);
  }

  void downVotePost(PostModel postModel) async {
    final user = _ref.read(userProvider)!;
    _postRepository.downVote(postModel, user.uid);
  }

  Stream<PostModel> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  void awardPost({
    required PostModel postModel,
    required String award,
    required BuildContext context,
  }) async {
    final user = _ref.read(userProvider)!;

    final res = await _postRepository.awardPost(postModel, award, user.uid);

    res.fold((l) => showSnackbar(context, l.message), (r) {
      _ref.read(userProfileControllerProvider.notifier).updateUserKarma(UserKarma.awardPost);
      _ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }
}
