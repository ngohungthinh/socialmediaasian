import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/domain/entities/app_user.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/posts/domain/entities/comment.dart';

class CommentTile extends StatefulWidget {
  final Comment comment;
  final bool isOwnPost;
  final void Function(Comment) onPressedDelete;
  const CommentTile({
    super.key,
    required this.comment,
    required this.onPressedDelete,
    this.isOwnPost = false,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  // current user
  AppUser? currentUser;
  bool isOwnComment = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final AuthCubit authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnComment =
        (currentUser!.uid == widget.comment.userId) || widget.isOwnPost;
  }

  // show confirm for deletion
  void showOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text("Delete Comment?"),
          actions: [
            TextButton(
              onPressed: () {
                widget.onPressedDelete(widget.comment);
                Navigator.of(context).pop();
              },
              child: const Text(
                "Delete",
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    getCurrentUser();
    return Container(
      padding: const EdgeInsets.only(left: 30, right: 15),
      child: Center(
        child: Row(
          children: [
            // name
            Text(
              widget.comment.userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 10,
            ),
            // comment text
            Expanded(child: Text(widget.comment.text)),

            // delete button
            if (isOwnComment)
              GestureDetector(
                onTap: showOptions,
                child: Icon(
                  Icons.more_horiz,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
