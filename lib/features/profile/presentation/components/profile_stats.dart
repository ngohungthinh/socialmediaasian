/*

PROFILE STATS

this will be displayed on all profile pages

------------------------------------------------------

Number of:

- posts
- followers
- following

*/

import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int postCount, followerCount, followingCount;
  final void Function()? onTap;
  const ProfileStats({
    super.key,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // text style for count
    late TextStyle textStyleForCount = TextStyle(
      fontSize: 20,
      color: Theme.of(context).colorScheme.inversePrimary,
    );

    // text style for text
    late TextStyle textStyleForText = TextStyle(
      color: Theme.of(context).colorScheme.primary,
    );
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // posts
            SizedBox(
              width: 100,
              child: Column(
                children: [
                  Text(
                    postCount.toString(),
                    style: textStyleForCount,
                  ),
                  Text(
                    "Posts",
                    style: textStyleForText,
                  ),
                ],
              ),
            ),
        
            // followers
            SizedBox(
              width: 100,
              child: Column(
                children: [
                  Text(
                    followerCount.toString(),
                    style: textStyleForCount,
                  ),
                  Text(
                    "Followers",
                    style: textStyleForText,
                  ),
                ],
              ),
            ),
        
            // following
            SizedBox(
              width: 100,
              child: Column(
                children: [
                  Text(
                    followingCount.toString(),
                    style: textStyleForCount,
                  ),
                  Text(
                    "Following",
                    style: textStyleForText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
