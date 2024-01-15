import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_danthocode_reddit/core/common/error_text.dart';
import 'package:flutter_danthocode_reddit/core/common/laoder.dart';
import 'package:flutter_danthocode_reddit/core/utils.dart';
import 'package:flutter_danthocode_reddit/features/community/controller/community_controller.dart';
import 'package:flutter_danthocode_reddit/features/post/controller/post_controller.dart';
import 'package:flutter_danthocode_reddit/models/community_model.dart';
import 'package:flutter_danthocode_reddit/theme/color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({
    Key? key,
    required this.type,
  }) : super(key: key);

  @override
  ConsumerState<AddPostTypeScreen> createState() => _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  List<CommunityModel> communities = [];
  CommunityModel? selectedCommunity;
  File? imageFile;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  void selectImage() async {
    final res = await pickImage();

    if (res != null) {
      imageFile = File(res.files.first.path!);
    }
  }

  void sharePost() {
    if (widget.type == 'image' && titleController.text.isNotEmpty && imageFile != null) {
      ref.read(postControllerProvider.notifier).postImage(
            context: context,
            title: titleController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
            file: imageFile,
          );
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).postText(
            context: context,
            title: titleController.text.trim(),
            description: descriptionController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
          );
    } else if (widget.type == 'link' && titleController.text.isNotEmpty && linkController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).postLink(
            context: context,
            title: titleController.text.trim(),
            link: linkController.text.trim(),
            selectedCommunity: selectedCommunity ?? communities[0],
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final isTypeImage = widget.type == 'image';
    final isTypeText = widget.type == 'text';
    final isTypeLink = widget.type == 'link';
    final isLoading = ref.watch(postControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Post ${widget.type}'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: sharePost,
            child: const Text('Share'),
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'Enter title here',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                    maxLength: 30,
                  ),
                  if (isTypeImage)
                    GestureDetector(
                      onTap: selectImage,
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        color: currentTheme.textTheme.bodyText2!.color!,
                        radius: const Radius.circular(10),
                        dashPattern: const [10, 4],
                        borderPadding: const EdgeInsets.all(4),
                        strokeCap: StrokeCap.round,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: imageFile != null
                              ? Image.file(imageFile!)
                              : const Icon(
                                  Icons.camera_alt_outlined,
                                ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (isTypeText)
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: 'Enter description here',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                      maxLines: 5,
                    ),
                  const SizedBox(height: 12),
                  if (isTypeLink)
                    TextField(
                      controller: linkController,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: 'Enter link here',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(18),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text('Select Community'),
                  ),
                  ref.watch(userCommunitiesProvider).when(
                        data: (data) {
                          communities = data;

                          if (data.isEmpty) {
                            return const SizedBox();
                          }
                          return DropdownButton(
                            value: selectedCommunity ?? data[0],
                            items: data.map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(e.name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedCommunity = val;
                              });
                            },
                          );
                        },
                        error: (error, stackTrace) => ErrorText(
                          error: error.toString(),
                        ),
                        loading: () => const Loader(),
                      ),
                ],
              ),
            ),
    );
  }
}
