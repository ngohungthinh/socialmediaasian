import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollowing;

  const FollowButton(
      {super.key, required this.onPressed, required this.isFollowing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: MaterialButton(
        padding: const EdgeInsets.all(25),
        shape:
            ContinuousRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: onPressed,
        color:
            isFollowing ? Theme.of(context).colorScheme.primary : Colors.blue,
        child: Center(
          child: Text(
            isFollowing ? "Unfollow" : "Follow",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
      ),
    );
  }
}
