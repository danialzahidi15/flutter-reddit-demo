import 'package:flutter/material.dart';
import 'package:flutter_danthocode_reddit/features/auth/screen/login_screen.dart';
import 'package:flutter_danthocode_reddit/features/community/screen/add_mods_screen.dart';
import 'package:flutter_danthocode_reddit/features/community/screen/community_screen.dart';
import 'package:flutter_danthocode_reddit/features/community/screen/create_community.dart';
import 'package:flutter_danthocode_reddit/features/community/screen/edit_community_screen.dart';
import 'package:flutter_danthocode_reddit/features/community/screen/mod_tools_screen.dart';
import 'package:flutter_danthocode_reddit/features/home/screen/home_screen.dart';
import 'package:flutter_danthocode_reddit/features/post/screen/add_post_type_screen.dart';
import 'package:flutter_danthocode_reddit/features/comment/screen/comment_screen.dart';
import 'package:flutter_danthocode_reddit/features/user_profile/screen/edit_profile_screen.dart';
import 'package:routemaster/routemaster.dart';

import 'features/user_profile/screen/user_profile_screen.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeScreen()),
  '/create-community': (_) => const MaterialPage(child: CreateCommunityScreen()),
  '/r/:name': (route) => MaterialPage(
          child: CommunityScreen(
        name: route.pathParameters['name']!,
      )),
  '/mod-tools/:name': (routeData) => MaterialPage(
          child: ModToolsScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/edit-community/:name': (routeData) => MaterialPage(
          child: EditCommunityScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/add-mods-screen/:name': (routeData) => MaterialPage(
          child: AddModsScreen(
        name: routeData.pathParameters['name']!,
      )),
  '/profile-screen/:uid': (routeData) => MaterialPage(
          child: UserProfileScreen(
        uid: routeData.pathParameters['uid']!,
      )),
  '/edit-profile/:uid': (routeData) => MaterialPage(
          child: EditProfileScreen(
        uid: routeData.pathParameters['uid']!,
      )),
  '/add-post/:type': (routeData) => MaterialPage(
          child: AddPostTypeScreen(
        type: routeData.pathParameters['type']!,
      )),
  '/post/:postId/comment': (route) => MaterialPage(
          child: CommentScreen(
        postId: route.pathParameters['postId']!,
      ))
});
