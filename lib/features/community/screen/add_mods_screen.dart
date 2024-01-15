import 'package:flutter/material.dart';
import 'package:flutter_danthocode_reddit/core/common/error_text.dart';
import 'package:flutter_danthocode_reddit/core/common/laoder.dart';
import 'package:flutter_danthocode_reddit/features/auth/controller/auth_controller.dart';
import 'package:flutter_danthocode_reddit/features/community/controller/community_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModsScreen({super.key, required this.name});

  @override
  ConsumerState<AddModsScreen> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  Set<String> uids = {};
  int counter = 0;

  void addMods(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeMods(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              ref.read(communityControllerProvider.notifier).addModerator(
                    widget.name,
                    uids.toList(),
                    context,
                  );
            },
            icon: const Icon(Icons.done),
          ),
        ],
      ),
      body: ref.watch(getCommunitybyNameProvider(widget.name)).when(
            data: (community) {
              return ListView.builder(
                itemCount: community.members.length,
                itemBuilder: (context, index) {
                  final member = community.members[index];

                  return ref.watch(getUserDataProvider(member)).when(
                        data: (user) {
                          if (community.mods.contains(member) && counter == 0) {
                            uids.add(member);
                          }
                          counter++;
                          return CheckboxListTile(
                            value: uids.contains(user.uid),
                            onChanged: (val) {
                              if (val!) {
                                addMods(user.uid);
                              } else {
                                removeMods(user.uid);
                              }
                            },
                            title: Text(user.name),
                          );
                        },
                        error: (error, stackTrace) => ErrorText(error: error.toString()),
                        loading: () => const Loader(),
                      );
                },
              );
            },
            error: (error, stackTrace) => ErrorText(
              error: error.toString(),
            ),
            loading: () => const Loader(),
          ),
    );
  }
}
