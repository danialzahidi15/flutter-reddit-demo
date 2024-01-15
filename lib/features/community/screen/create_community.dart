import 'package:flutter/material.dart';
import 'package:flutter_danthocode_reddit/core/common/laoder.dart';
import 'package:flutter_danthocode_reddit/features/community/controller/community_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateCommunityScreen extends ConsumerStatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateCommunityState();
}

class _CreateCommunityState extends ConsumerState<CreateCommunityScreen> {
  final communityController = TextEditingController();

  @override
  void dispose() {
    communityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Create Community'),
      ),
      body: isLoading
          ? const Loader()
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Community name',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: communityController,
                    decoration: const InputDecoration(
                      hintText: 'r/Community name',
                      filled: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(18),
                    ),
                    maxLength: 21,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(communityControllerProvider.notifier).createCommunity(
                            context,
                            communityController.text.trim(),
                          );
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(side: BorderSide.none, borderRadius: BorderRadius.circular(20))),
                    child: const Text(
                      'Create community',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
