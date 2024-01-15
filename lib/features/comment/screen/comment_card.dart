import 'package:flutter/material.dart';
import 'package:flutter_danthocode_reddit/models/comment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentCard extends ConsumerWidget {
  final CommentModel commentModel;
  const CommentCard({super.key, required this.commentModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(commentModel.profilePic),
          radius: 18,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'u/${commentModel.username}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(commentModel.text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
