import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/domain/entities/app_user.dart';
import 'package:social_media/features/auth/presentation/components/my_textfield.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/posts/domain/entities/comment.dart';
import 'package:social_media/features/posts/domain/entities/post.dart';
import 'package:social_media/features/posts/presentation/components/comment_tile.dart';
import 'package:social_media/features/posts/presentation/cubits/post_cubit.dart';
import 'package:social_media/features/posts/presentation/cubits/post_states.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media/features/profile/presentation/pages/profile_page.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;
  final bool isToProfile;
  const PostTile(
      {super.key,
      required this.post,
      required this.onDeletePressed,
      this.isToProfile = true});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  // cubits
  late final PostCubit postCubit = context.read<PostCubit>();
  late final ProfileCubit profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;

  // current user
  AppUser? currentUser;

  // post user
  ProfileUser? postUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final AuthCubit authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = widget.post.userId == currentUser!.uid;
  }

  void fetchPostUser() async {
    postUser = await profileCubit.getUserProfile(widget.post.userId);
    // If Widget con tren Widget Tree thi moi update.
    if (mounted) {
      setState(() {});
    }
  }

  /*

  LIKE
  
  */

  // user tapped like button
  void toggleLikePost() async {
    // current like status
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    // optimistically like & update UI
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid); // unlike
      } else {
        widget.post.likes.add(currentUser!.uid); // like
      }
    });

    // update like
    postCubit
        .toggleLikePost(widget.post.id, currentUser!.uid, !isLiked)
        .catchError((onError) {
      // if there's an error, revert back to original values
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid); // revert unlike -> like
        } else {
          widget.post.likes.remove(currentUser!.uid); // revert like -> unlike
        }
      });
    });
  }

  /*

  COMMENT

  */
  // comment text controller
  final commentTextController = TextEditingController();

  // open commnet box -> user wants to type a new comment
  void openNewCommentBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              title: const Text("Add a new comment"),
              content: MyTextfield(
                  hintText: "Type a comment",
                  obscureText: false,
                  controller: commentTextController),
              actions: [
                // save button
                TextButton(
                  onPressed: () {
                    addComment();
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary),
                  ),
                ),

                // cancel button
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
              ],
            )).then((value) => commentTextController.clear());
  }

  void addComment() {
    // create a new comment
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: commentTextController.text,
      timestamp: DateTime.now(),
    );

    // add comment using cubit
    if (commentTextController.text.isNotEmpty) {
      setState(() {
        widget.post.comments.add(newComment);
      });

      // Add that su. Neu add khong than cong thi revert lai
      postCubit.addComment(widget.post.id, newComment).catchError((error) {
        setState(() {
          widget.post.comments.remove(newComment);
        });
      });
    }
  }

  void deleteComment(Comment commentDelete) {
    // Update đỡ UI
    setState(() {
      widget.post.comments
          .removeWhere((comment) => comment.id == commentDelete.id);
    });

    // Thật sự xóa ở phía database. Nếu có lỗi thì reverst lại
    // Nhưng bên phía Cubit không phát ra lỗi. Thật là hài.
    postCubit.deleteComment(widget.post.id, commentDelete.id).catchError((e) {
      setState(() {
        widget.post.comments.add(commentDelete);
      });
    });
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
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
          title: const Text("Delete Post?"),
          actions: [
            TextButton(
              onPressed: () {
                widget.onDeletePressed!();
                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
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
    fetchPostUser();
    // get date post
    DateTime date = widget.post.timestamp;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          // top section
          GestureDetector(
            onTap: () {
              if (widget.isToProfile) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(
                      uid: widget.post.userId,
                    ),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // avatar
                  postUser?.profileImageUrl != null
                      ? Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: CachedNetworkImage(
                            width: 40,
                            height: 40,
                            imageUrl: postUser!.profileImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Icon(
                              Icons.person,
                              size: 27,
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.person,
                              size: 27,
                            ),
                          ),
                        )
                      : const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.person,
                            size: 20,
                          ),
                        ),
                        
                  const SizedBox(width: 7),

                  // name
                  Text(
                    widget.post.userName,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontWeight: FontWeight.bold),
                  ),

                  const Spacer(),

                  // delete button
                  if (isOwnPost)
                    GestureDetector(
                      onTap: showOptions,
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // image
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 500),
            child: CachedNetworkImage(
              imageUrl: widget.post.imageUrl,
              width: double.maxFinite,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),

          // button -> like, comment, timestamp
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
            child: Row(
              children: [
                // like button
                SizedBox(
                  width: 50,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: toggleLikePost,
                        child: widget.post.likes.contains(currentUser!.uid)
                            ? const Icon(Icons.favorite, color: Colors.red)
                            : Icon(Icons.favorite_border,
                                color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        widget.post.likes.length.toString(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // comment button
                Row(
                  children: [
                    GestureDetector(
                        onTap: openNewCommentBox,
                        child: Icon(
                          Icons.comment,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      widget.post.comments.length.toString(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12),
                    ),
                  ],
                ),

                const Spacer(),

                // timestamp
                Text(
                    '${date.year}-${date.month}-${date.year}  ${date.hour}:${date.minute}'),
              ],
            ),
          ),

          // CAPTION
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // username
                Text(
                  widget.post.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(
                  width: 10,
                ),

                // text
                Expanded(child: Text(widget.post.text)),
              ],
            ),
          ),

          Divider(
            thickness: 0.1,
            height: 0,
            color: Theme.of(context).colorScheme.primary,
          ),

          // COMMENT SECTION
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              // LOADED
              if (state is PostsLoaded) {
                //final individual post
                // ??? doan code
                // final post = state.posts
                //     .firstWhere((post) => (post.id == widget.post.id));

                // Don gian hon ne
                final post = widget.post;

                if (post.comments.isNotEmpty) {
                  // how many comments to show
                  int showCommentCount = post.comments.length;

                  //comment section
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: showCommentCount,
                    itemBuilder: (context, index) {
                      // get individual comment
                      final comment = post.comments[index];

                      // comment tile UI
                      return CommentTile(
                        comment: comment,
                        isOwnPost: isOwnPost,
                        onPressedDelete: deleteComment,
                      );
                    },
                  );
                }
              }

              // LOADING...
              if (state is PostsLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // ERROR
              else if (state is PostsError) {
                return Center(
                  child: Text(state.message),
                );
              } else {
                return const Center(
                  child: SizedBox(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
