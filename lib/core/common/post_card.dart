import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_danthocode_reddit/core/common/error_text.dart';
import 'package:flutter_danthocode_reddit/core/common/laoder.dart';
import 'package:flutter_danthocode_reddit/core/constants/asset_constants.dart';
import 'package:flutter_danthocode_reddit/features/auth/controller/auth_controller.dart';
import 'package:flutter_danthocode_reddit/features/post/controller/post_controller.dart';
import 'package:flutter_danthocode_reddit/models/post_model.dart';
import 'package:flutter_danthocode_reddit/theme/color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import '../../features/community/controller/community_controller.dart';

class PostCard extends ConsumerWidget {
  final PostModel post;
  const PostCard({
    super.key,
    required this.post,
  });

  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push('/profile-screen/${post.uid}');
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeText = post.type == 'text';
    final isTypeImage = post.type == 'image';
    final isTypeLink = post.type == 'link';
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    final totalVotes = post.upvotes.length - post.downvotes.length;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: currentTheme.drawerTheme.backgroundColor,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 16,
                            ).copyWith(right: 0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => navigateToCommunity(context),
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(post.communityProfilePic),
                                    radius: 20,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'r/${post.communityName}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => navigateToUser(context),
                                          child: Text(
                                            'u/${post.username}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (post.uid == user.uid)
                                  IconButton(
                                    onPressed: () {
                                      ref.read(postControllerProvider.notifier).deletePost(context, post);
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: RedditColor.redColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (post.awards.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: SizedBox(
                                height: 25,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: post.awards.length,
                                  itemBuilder: (context, index) {
                                    final award = post.awards[index];

                                    return Image.asset(
                                      AssetConstants.awards[award]!,
                                      height: 24,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isTypeImage)
                            Container(
                              padding: const EdgeInsets.only(top: 4),
                              height: MediaQuery.of(context).size.height * 0.35,
                              width: double.infinity,
                              child: Image.network(
                                post.link!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (isTypeLink)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              child: AnyLinkPreview(
                                displayDirection: UIDirection.uiDirectionHorizontal,
                                link: post.link!,
                              ),
                            ),
                          if (isTypeText)
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                post.description!,
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: isGuest
                                        ? () {}
                                        : () {
                                            ref.read(postControllerProvider.notifier).upvotePost(post);
                                          },
                                    icon: Icon(
                                      AssetConstants.up,
                                      size: 30,
                                      color: post.upvotes.contains(user.uid) ? RedditColor.redColor : null,
                                    ),
                                  ),
                                  Text(
                                    '${totalVotes == 0 ? 'Votes' : totalVotes}',
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                  IconButton(
                                    onPressed: isGuest
                                        ? () {}
                                        : () {
                                            ref.read(postControllerProvider.notifier).downVotePost(post);
                                          },
                                    icon: Icon(
                                      AssetConstants.down,
                                      size: 30,
                                      color: post.downvotes.contains(user.uid) ? RedditColor.blueColor : null,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Routemaster.of(context).push('/post/${post.postId}/comment');
                                    },
                                    icon: const Icon(Icons.comment),
                                  ),
                                  Text(
                                    '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                ],
                              ),
                              ref.watch(getCommunitybyNameProvider(post.communityName)).when(
                                    data: (data) {
                                      if (data.mods.contains(user.uid)) {
                                        return IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.admin_panel_settings),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                    error: (error, stackTrace) => ErrorText(error: error.toString()),
                                    loading: () => const Loader(),
                                  ),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: GridView.builder(
                                          shrinkWrap: true,
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                          ),
                                          itemCount: user.awards.length,
                                          itemBuilder: (context, index) {
                                            final award = user.awards[index];

                                            return GestureDetector(
                                              onTap: () {
                                                ref.read(postControllerProvider.notifier).awardPost(
                                                      postModel: post,
                                                      award: award,
                                                      context: context,
                                                    );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Image.asset(
                                                  AssetConstants.awards[award]!,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.card_giftcard_outlined),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
