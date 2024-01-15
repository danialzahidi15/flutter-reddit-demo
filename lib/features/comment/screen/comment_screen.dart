import 'package:flutter/material.dart';
import 'package:flutter_danthocode_reddit/core/common/error_text.dart';
import 'package:flutter_danthocode_reddit/core/common/laoder.dart';
import 'package:flutter_danthocode_reddit/core/common/post_card.dart';
import 'package:flutter_danthocode_reddit/features/comment/controller/comment_controller.dart';
import 'package:flutter_danthocode_reddit/features/comment/screen/comment_card.dart';
import 'package:flutter_danthocode_reddit/features/post/controller/post_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentScreen({super.key, required this.postId});

  @override
  ConsumerState<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
            data: (data) {
              return Column(
                children: [
                  PostCard(post: data),
                  const SizedBox(height: 8),
                  TextField(
                    onSubmitted: (value) {
                      ref.read(commentControllerProvider.notifier).postComment(
                            context: context,
                            text: commentController.text.trim(),
                            postModel: data,
                          );
                      setState(() {
                        commentController.text = '';
                      });
                    },
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'What are your thoughts?',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  ref.watch(getAllCommentOfPostProvider(widget.postId)).when(
                        data: (data) {
                          return Expanded(
                            child: ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  final comment = data[index];

                                  return CommentCard(commentModel: comment);
                                }),
                          );
                        },
                        error: (error, stackTrace) {
                          return ErrorText(error: error.toString());
                        },
                        loading: () => const Loader(),
                      ),
                ],
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
