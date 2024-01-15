import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_danthocode_reddit/features/auth/controller/auth_controller.dart';
import 'package:flutter_danthocode_reddit/features/user_profile/controller/user_profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/common/error_text.dart';
import '../../../core/common/laoder.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/utils.dart';
import '../../../theme/color.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({super.key, required this.uid});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  File? profileFile;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

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

  void saveProfile() async {
    ref.read(userProfileControllerProvider.notifier).editUser(
          context: context,
          profileFile: profileFile,
          bannerFile: bannerFile,
          name: nameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userProfileControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
          data: (user) {
            return Scaffold(
              backgroundColor: currentTheme.backgroundColor,
              appBar: AppBar(
                elevation: 0,
                centerTitle: false,
                title: const Text('Edit Profile'),
                actions: [
                  TextButton(
                    onPressed: saveProfile,
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
                                          : user.banner.isEmpty || user.banner == AssetConstants.bannerDefault
                                              ? const Icon(Icons.camera_alt_outlined, size: 40)
                                              : Image.network(user.banner),
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
                                              user.profilePic,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                                filled: true,
                                hintText: 'Name',
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(18)),
                          )
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
