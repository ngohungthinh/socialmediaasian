import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/domain/entities/app_user.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/posts/data/firebase_post_repo.dart';
import 'package:social_media/features/posts/domain/entities/post.dart';
import 'package:social_media/features/posts/presentation/components/post_tile.dart';
import 'package:social_media/features/posts/presentation/cubits/post_cubit.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/presentation/components/bio_box.dart';
import 'package:social_media/features/profile/presentation/components/follow_button.dart';
import 'package:social_media/features/profile/presentation/components/profile_stats.dart';
import 'package:social_media/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media/features/profile/presentation/cubits/profile_states.dart';
import 'package:social_media/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:social_media/features/profile/presentation/pages/follower_page.dart';
import 'package:social_media/responsive/widget_max_width_465.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final FirebasePostRepo firebasePostRepo = FirebasePostRepo();
  // cubits
  late final AuthCubit authCubit = context.read<AuthCubit>();
  late final ProfileCubit profileCubit = context.read<ProfileCubit>();

  // current user
  late AppUser? currentUser = authCubit.currentUser;

  // so luong post
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();

    // load user profile data
    profileCubit.fetchUserProfile(widget.uid);

    //  posts = firebasePostRepo.fetchPostByUserId(widget.uid);
  }

  /*

  FOLLOW / UNFOLLOW

  */

  void followButtonPressed() {
    final ProfileState profileState = profileCubit.state;

    // Neu chua load xong profile thi khong lam gi ca
    if (profileState is! ProfileLoaded) {
      return;
    }

    final ProfileUser profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    // optimistically update UI
    setState(() {
      // unfollow
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      }

      // follow
      else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    // perform actual toggle in cubit
    profileCubit
        .toggleFollow(currentUser!.uid, widget.uid, !isFollowing)
        .catchError((e) {
      setState(() {
        // unfollow
        if (isFollowing) {
          profileUser.followers.add(currentUser!.uid);
        }

        // follow
        else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    });
  }

  // delete Post
  void deletePost(int index) {
    // That su xoa
    context.read<PostCubit>().deletePost(
          posts[index].id,
          posts[index].imageUrl,
        );

    // update ui
    setState(() {
      posts.removeAt(index);
    });

    // fetch lai post cho homepage
    context.read<PostCubit>().fetchAllPosts();
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // is Own post
    bool isOwnPost = (widget.uid == currentUser?.uid);

    // 3 truong hop state
    return WidgetMaxWidth465(
      child: FutureBuilder(
        future: firebasePostRepo.fetchPostByUserId(widget.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            posts = snapshot.data!;
          }
          return BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              print(state);

              // loaded
              if (state is ProfileLoaded) {
                // get loaded user
                final user = state.profileUser;

                // BUILD UI

                return Scaffold(
                  appBar: AppBar(
                    centerTitle: true,
                    title: Text(user.name),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    actions: [
                      // edit profile button
                      if (isOwnPost)
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditProfilePage(
                                            user: user,
                                          )));
                            },
                            icon: const Icon(Icons.settings)),
                    ],
                  ),
                  body: ListView(
                    children: [
                      // email
                      Center(
                        child: Text(
                          user.email,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // profile pic
                      Center(
                        child: Container(
                          height: 120,
                          width: 120,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          child:
                              // Cái ảnh là lấy url load riêng.
                              CachedNetworkImage(
                            imageUrl: user.profileImageUrl,
                            // loading...
                            placeholder: (context, url) => const CircularProgressIndicator(),

                            // error -> failed to load
                            errorWidget: (context, url, error) => Icon(
                              Icons.person,
                              size: 72,
                              color: Theme.of(context).colorScheme.primary,
                            ),

                            // loaded
                            imageBuilder: (context, imageProvider) => Image(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // profile stats
                      ProfileStats(
                        postCount: posts.length,
                        followerCount: user.followers.length,
                        followingCount: user.following.length,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FollowerPage(
                                followers: user.followers,
                                following: user.following,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 25),

                      // Follow Button
                      if (!isOwnPost)
                        FollowButton(
                            onPressed: followButtonPressed,
                            isFollowing:
                                user.followers.contains(currentUser!.uid)),
                      const SizedBox(height: 25),

                      // Bio
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Row(
                          children: [
                            Text(
                              'Bio',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      BioBox(bioText: user.bio),

                      const SizedBox(height: 25),

                      // Post
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Row(
                          children: [
                            Text(
                              'Post ',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // list of posts from this user
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          // get individual post
                          final post = posts[index];

                          return PostTile(
                            post: post,
                            onDeletePressed: () {
                              deletePost(index);
                            },
                            isToProfile: false,
                          );
                        },
                      ),
                    ],
                  ),
                );
              }
              // loading ....
              else if (state is ProfileLoading) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              // Error
              else {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text("Profile Page"),
                  ),
                  body: Center(
                    child: Text((state as ProfileError).message),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
