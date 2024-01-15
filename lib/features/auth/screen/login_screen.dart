import 'package:flutter/material.dart';
import 'package:flutter_danthocode_reddit/core/common/laoder.dart';
import 'package:flutter_danthocode_reddit/core/common/sign_in_button.dart';
import 'package:flutter_danthocode_reddit/core/constants/asset_constants.dart';
import 'package:flutter_danthocode_reddit/features/auth/controller/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          AssetConstants.logo,
          height: 40,
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).signinAnonymously(context);
            },
            child: const Text('Skip'),
          ),
        ],
      ),
      body: isLoading
          ? const Loader()
          : Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Dive into anything',
                  style: TextStyle(
                    letterSpacing: 0.5,
                    fontSize: 36,
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Image.asset(
                    AssetConstants.loginEmote,
                    height: 400,
                  ),
                ),
                const SizedBox(height: 20),
                const SignInButton()
              ],
            ),
    );
  }
}
