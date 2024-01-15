import 'package:flutter/material.dart';
import 'package:flutter_danthocode_reddit/core/enum/enum.dart';
import 'package:flutter_danthocode_reddit/features/auth/controller/auth_controller.dart';
import 'package:flutter_danthocode_reddit/theme/color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.profilePic),
              radius: 70,
            ),
            const SizedBox(height: 8),
            Text(
              'u/${user.name}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(),
            isGuest
                ? const SizedBox()
                : ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('My Profile'),
                    onTap: () {
                      Routemaster.of(context).push('/profile-screen/${user.uid}');
                    },
                  ),
            isGuest
                ? const SizedBox()
                : ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    title: const Text('Log Out'),
                    onTap: () {
                      ref.read(authControllerProvider.notifier).logout();
                    },
                  ),
            isGuest
                ? const SizedBox()
                : Switch.adaptive(
                    value: ref.watch(themeNotifierProvider.notifier).mode == ThemeMethod.dark,
                    onChanged: (val) {
                      ref.read(themeNotifierProvider.notifier).toggleTheme();
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
