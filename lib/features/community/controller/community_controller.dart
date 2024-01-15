import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_danthocode_reddit/core/constants/asset_constants.dart';
import 'package:flutter_danthocode_reddit/core/failure.dart';
import 'package:flutter_danthocode_reddit/core/providers/firebase_storage_provider.dart';
import 'package:flutter_danthocode_reddit/core/utils.dart';
import 'package:flutter_danthocode_reddit/features/auth/controller/auth_controller.dart';
import 'package:flutter_danthocode_reddit/features/community/repository/community_repo.dart';
import 'package:flutter_danthocode_reddit/models/community_model.dart';
import 'package:flutter_danthocode_reddit/models/post_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod/riverpod.dart';
import 'package:routemaster/routemaster.dart';

final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});

final communityControllerProvider = StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return CommunityController(
    communityRepository,
    ref,
    storageRepository,
  );
});

final getCommunitybyNameProvider = StreamProvider.family((ref, String name) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getCommunity(name);
});

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.searchCommunity(query);
});

final getCommunityPostProvider = StreamProvider.family((ref, String name) {
  final communityController = ref.read(communityControllerProvider.notifier);
  return communityController.getCommunityPost(name);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  CommunityController(
    CommunityRepository communityRepository,
    Ref ref,
    StorageRepository storageRepository,
  )   : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void createCommunity(BuildContext context, String name) async {
    state = true;
    final uid = _ref.read(userProvider)!.uid;
    CommunityModel community = CommunityModel(
      id: name,
      name: name,
      banner: AssetConstants.bannerDefault,
      avatar: AssetConstants.avatarDefault,
      members: [uid],
      mods: [uid],
    );

    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) {
        showSnackbar(context, 'Community created Successfully!');
        Routemaster.of(context).pop();
      },
    );
  }

  void joinCommunity(CommunityModel community, BuildContext context) async {
    final user = _ref.read(userProvider)!;

    Either<Failure, void> res;
    if (community.members.contains(user.uid)) {
      res = await _communityRepository.leaveCommunity(community.name, user.uid);
    } else {
      res = await _communityRepository.joinCommunity(community.name, user.uid);
    }

    res.fold((l) => showSnackbar(context, l.message), (r) {
      if (community.members.contains(user.uid)) {
        showSnackbar(context, '${user.name} left ${community.name}');
      } else {
        showSnackbar(context, '${user.name} joined ${community.name}');
      }
    });
  }

  Stream<List<CommunityModel>> getUserCommunities() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunity(uid);
  }

  Stream<CommunityModel> getCommunity(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  void editCommunity({
    required BuildContext context,
    required File? profileFile,
    required File? bannerFile,
    required CommunityModel community,
  }) async {
    state = true;
    if (profileFile != null) {
      final res = await _storageRepository.uploadImage(
        path: 'communities/profile',
        id: community.name,
        file: profileFile,
      );

      res.fold(
        (l) => showSnackbar(context, l.message),
        (r) => community = community.copyWith(avatar: r),
      );
    }

    if (bannerFile != null) {
      final res = await _storageRepository.uploadImage(
        path: 'communities/banner',
        id: community.name,
        file: bannerFile,
      );

      res.fold(
        (l) => showSnackbar(context, l.message),
        (r) => community = community.copyWith(banner: r),
      );
    }

    final res = await _communityRepository.editCommunity(community);

    state = false;
    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  Stream<List<CommunityModel>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  void addModerator(String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addModerators(communityName, uids);
    res.fold(
      (l) => showSnackbar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  Stream<List<PostModel>> getCommunityPost(String name) {
    return _communityRepository.getCommunityPosts(name);
  }
}
