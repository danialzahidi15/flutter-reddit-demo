// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_danthocode_reddit/theme/color.dart';
import 'package:routemaster/routemaster.dart';

class AddPostScreen extends ConsumerWidget {
  const AddPostScreen({super.key});

  void navigateToType(BuildContext context, String type) {
    Routemaster.of(context).push('/add-post/$type');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double cardSize = 120;
    double iconSize = 60;
    final currentTheme = ref.watch(themeNotifierProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AddPostButton(
          cardSize: cardSize,
          currentTheme: currentTheme,
          iconSize: iconSize,
          icon: Icons.image_outlined,
          onTap: () => navigateToType(context, 'image'),
        ),
        AddPostButton(
          cardSize: cardSize,
          currentTheme: currentTheme,
          iconSize: iconSize,
          icon: Icons.font_download_outlined,
          onTap: () => navigateToType(context, 'text'),
        ),
        AddPostButton(
          cardSize: cardSize,
          currentTheme: currentTheme,
          iconSize: iconSize,
          icon: Icons.link_outlined,
          onTap: () => navigateToType(context, 'link'),
        ),
      ],
    );
  }
}

class AddPostButton extends StatelessWidget {
  const AddPostButton({
    Key? key,
    required this.cardSize,
    required this.currentTheme,
    required this.iconSize,
    this.onTap,
    required this.icon,
  }) : super(key: key);

  final double cardSize;
  final ThemeData currentTheme;
  final double iconSize;
  final Function()? onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: cardSize,
        width: cardSize,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: currentTheme.backgroundColor,
          elevation: 16,
          child: Icon(
            icon,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
