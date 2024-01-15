import 'package:flutter/material.dart';
import 'package:flutter_danthocode_reddit/core/common/error_text.dart';
import 'package:flutter_danthocode_reddit/core/common/laoder.dart';
import 'package:flutter_danthocode_reddit/features/auth/controller/auth_controller.dart';
import 'package:flutter_danthocode_reddit/features/community/controller/community_controller.dart';
import 'package:flutter_danthocode_reddit/models/community_model.dart';
import 'package:flutter_danthocode_reddit/theme/color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navigateToCreateCommunityScreen(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunityScreen(BuildContext context, CommunityModel community) {
    Routemaster.of(context).push('/r/${community.name}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCommunities = ref.watch(userCommunitiesProvider);
    final user = ref.read(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final currentTheme = ref.read(themeNotifierProvider);
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            isGuest
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(authControllerProvider.notifier).logout();
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Go to Login Screen'),
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 40),
                          backgroundColor: currentTheme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )),
                    ),
                  )
                : ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add Community'),
                    onTap: () => navigateToCreateCommunityScreen(context),
                  ),
            if (!isGuest)
              userCommunities.when(
                data: (communities) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: communities.length,
                      itemBuilder: (context, index) {
                        final community = communities[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(community.avatar),
                          ),
                          title: Text('r/${community.name}'),
                          onTap: () {
                            navigateToCommunityScreen(context, community);
                          },
                        );
                      },
                    ),
                  );
                },
                error: (error, stackTrace) => ErrorText(error: error.toString()),
                loading: () => const Loader(),
              ),
          ],
        ),
      ),
    );
  }
}
