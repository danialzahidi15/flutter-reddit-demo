import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_danthocode_reddit/core/common/error_text.dart';
import 'package:flutter_danthocode_reddit/core/common/laoder.dart';
import 'package:flutter_danthocode_reddit/core/constants/asset_constants.dart';
import 'package:flutter_danthocode_reddit/core/utils.dart';
import 'package:flutter_danthocode_reddit/features/community/controller/community_controller.dart';
import 'package:flutter_danthocode_reddit/theme/color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<EditCommunityScreen> createState() => _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? profileFile;

  void selectBanner() async {
    final res = await pickImage();

    if (res != null) {
      bannerFile = File(res.files.first.path!);
    }
  }

  void selectProfile() async {
    final res = await pickImage();

    if (res != null) {
      profileFile = File(res.files.first.path!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);
    return ref.watch(getCommunitybyNameProvider(widget.name)).when(
          data: (community) {
            return Scaffold(
              backgroundColor: currentTheme.backgroundColor,
              appBar: AppBar(
                elevation: 0,
                centerTitle: false,
                title: const Text('Edit Community'),
                actions: [
                  TextButton(
                    onPressed: () {
                      ref.read(communityControllerProvider.notifier).editCommunity(
                            context: context,
                            profileFile: profileFile,
                            bannerFile: bannerFile,
                            community: community,
                          );
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
              body: isLoading
                  ? const Loader()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: selectBanner,
                                  child: DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(10),
                                    dashPattern: const [10, 4],
                                    borderPadding: const EdgeInsets.all(4),
                                    strokeCap: StrokeCap.round,
                                    color: currentTheme.textTheme.bodyText2!.color!,
                                    child: Container(
                                      height: 150,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: bannerFile != null
                                          ? Image.file(bannerFile!)
                                          : community.banner.isEmpty || community.banner == AssetConstants.bannerDefault
                                              ? const Icon(Icons.camera_alt_outlined, size: 40)
                                              : Image.network(community.banner),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  child: GestureDetector(
                                    onTap: selectProfile,
                                    child: profileFile != null
                                        ? CircleAvatar(
                                            radius: 32,
                                            backgroundImage: FileImage(profileFile!),
                                          )
                                        : CircleAvatar(
                                            radius: 32,
                                            backgroundImage: NetworkImage(
                                              community.avatar,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
          loading: () => const Loader(),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
        );
  }
}
