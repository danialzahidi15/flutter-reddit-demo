import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_danthocode_reddit/core/enum/enum.dart';
import 'package:flutter_danthocode_reddit/core/providers/firebase_storage_provider.dart';
import 'package:flutter_danthocode_reddit/core/utils.dart';
import 'package:flutter_danthocode_reddit/features/auth/controller/auth_controller.dart';
import 'package:flutter_danthocode_reddit/features/user_profile/repository/user_profile_repositary.dart';
import 'package:flutter_danthocode_reddit/models/post_model.dart';
import 'package:flutter_danthocode_reddit/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

final userProfileControllerProvider = StateNotifierProvider<UserProfileController, bool>((ref) {
  final userProfileRepository = ref.watch(userProfileRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return UserProfileController(
    userProfileRepository: userProfileRepository,
    ref: ref,
    storageRepository: storageRepository,
  );
});

final getUserPostsProvider = StreamProvider.family((ref, String uid) {
  final userProfileController = ref.read(userProfileControllerProvider.notifier).getUserPosts(uid);
  return userProfileController;
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  UserProfileController({
    required UserProfileRepository userProfileRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  })  : _userProfileRepository = userProfileRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void editUser({
    required BuildContext context,
    required File? profileFile,
    required File? bannerFile,
    required String? name,
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;
    if (profileFile != null) {
      final res = await _storageRepository.uploadImage(
        path: 'users/profile',
        id: user.uid,
        file: profileFile,
      );

      res.fold(
        (l) => showSnackbar(context, l.message),
        (r) => user = user.copyWith(profilePic: r),
      );
    }

    if (bannerFile != null) {
      final res = await _storageRepository.uploadImage(
        path: 'users/banner',
        id: user.uid,
        file: bannerFile,
      );

      res.fold(
        (l) => showSnackbar(context, l.message),
        (r) => user = user.copyWith(banner: r),
      );
    }

    user = user.copyWith(name: name);

    final res = await _userProfileRepository.editUser(user);

    state = false;
    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) {
        _ref.read(userProvider.notifier).update((state) => user);
        Routemaster.of(context).pop();
      },
    );
  }

  Stream<List<PostModel>> getUserPosts(String uid) {
    return _userProfileRepository.getUserPosts(uid);
  }

  void updateUserKarma(UserKarma karma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + karma.karma);

    final res = await _userProfileRepository.updateUserKarma(user);
    res.fold(
      (l) => null,
      (r) => _ref.read(userProvider.notifier).update((state) => user),
    );
  }
}
