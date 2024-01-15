import 'package:flutter/cupertino.dart';
import 'package:flutter_danthocode_reddit/features/feed/screen/feed_screen.dart';
import 'package:flutter_danthocode_reddit/features/post/screen/add_post_screen.dart';

class AssetConstants {
  static const String _path = 'assets/images';
  // static const String awesomeAnswer = '$_path/awards/awesomeanswer.png';
  // static const String gold = '$_path/awards/gold.png';
  // static const String helpful = '$_path/awards/helpful.png';
  // static const String platinum = '$_path/awards/platinum.png';
  // static const String plusone = '$_path/awards/plusone.png';
  // static const String rocket = '$_path/awards/rocket.png';
  // static const String thankyou = '$_path/awards/thankyou.png';
  // static const String til = '$_path/awards/til.png';
  static const String google = '$_path/google.png';
  static const String loginEmote = '$_path/loginEmote.png';
  static const String logo = '$_path/logo.png';

  static const bannerDefault =
      'https://thumbs.dreamstime.com/b/abstract-stained-pattern-rectangle-background-blue-sky-over-fiery-red-orange-color-modern-painting-art-watercolor-effe-texture-123047399.jpg';
  static const avatarDefault = 'https://www.redditstatic.com/avatars/avatar_default_02_A5A4A4.png';

  static const IconData up = IconData(0xe800, fontFamily: 'MyFlutterApp', fontPackage: null);
  static const IconData down = IconData(0xe801, fontFamily: 'MyFlutterApp', fontPackage: null);

  static const tabWidgets = [
    FeedScreen(),
    AddPostScreen(),
  ];

  static const awardPath = 'assets/images/awards';

  static const awards = {
    'awesomeanswer': '${AssetConstants.awardPath}/awesomeanswer.png',
    'gold': '${AssetConstants.awardPath}/gold.png',
    'helpful': '${AssetConstants.awardPath}/helpful.png',
    'platinum': '${AssetConstants.awardPath}/platinum.png',
    'plusone': '${AssetConstants.awardPath}/plusone.png',
    'rocket': '${AssetConstants.awardPath}/rocket.png',
    'thankyou': '${AssetConstants.awardPath}/thankyou.png',
    'til': '${AssetConstants.awardPath}/til.png',
  };
}
