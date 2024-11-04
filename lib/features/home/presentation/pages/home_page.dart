import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/home/presentation/components/my_drawer.dart';
import 'package:social_media/features/posts/presentation/components/post_tile.dart';
import 'package:social_media/features/posts/presentation/cubits/post_cubit.dart';
import 'package:social_media/features/posts/presentation/cubits/post_states.dart';
import 'package:social_media/features/posts/presentation/pages/upload_post_page.dart';
import 'package:social_media/responsive/widget_max_width_465.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // post cubit
  late final postCubit = context.read<PostCubit>();

  @override
  void initState() {
    super.initState();

    // fetch all posts
    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetMaxWidth465(
      child: Center(
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(shape: BoxShape.rectangle),
          width: 465,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              foregroundColor: Theme.of(context).colorScheme.primary,
              title: const Text("Home"),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UploadPostPage()));
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.blue,
                      size: 35,
                    )),
              ],
            ),
            drawer: const MyDrawer(),
            body: BlocBuilder<PostCubit, PostState>(
              builder: (context, state) {
                print(state);
                //loading...
                if (state is PostsLoading || state is PostsUploading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // loaded
                else if (state is PostsLoaded) {
                  final allPosts = state.posts;

                  if (allPosts.isEmpty) {
                    return const Center(
                      child: Text("No posts available"),
                    );
                  }

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: allPosts
                          .map((post) => PostTile(
                              post: post,
                              onDeletePressed: () {
                                // Ham xoa Post
                                setState(() {
                                  state.posts.remove(post);
                                });

                                postCubit.deletePost(post.id, post.imageUrl);
                              }))
                          .toList(),
                      // : (context, index) {
                      //   // get individual post
                      //   final post = allPosts[index];

                      //   return PostTile(
                      //       post: post,
                      //       onDeletePressed: () {
                      //         // Ham xoa Post
                      //         setState(() {
                      //           state.posts.removeAt(index);
                      //         });

                      //         postCubit.deletePost(post.id, post.imageUrl);
                      //       });
                      // },
                    ),
                  );
                }

                // error
                else if (state is PostsError) {
                  return Center(
                    child: Text(state.message),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
