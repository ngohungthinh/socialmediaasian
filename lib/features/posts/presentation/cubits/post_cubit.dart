import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/posts/domain/entities/comment.dart';
import 'package:social_media/features/posts/domain/entities/post.dart';
import 'package:social_media/features/posts/domain/repos/post_repo.dart';
import 'package:social_media/features/posts/presentation/cubits/post_states.dart';
import 'package:social_media/features/storage/domain/storage_repo.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({
    required this.postRepo,
    required this.storageRepo,
  }) : super(PostsInitial());

  // create a new post
  Future<void> createPost(
    Post post, {
    String? imagePath,
    Uint8List? imageBytes,
  }) async {
    String? imageUrl;
    try {
      // handle image upload for mobile platforms (using file path)
      if (imagePath != null) {
        emit(PostsUploading());
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, post.id);
      }

      // handle image upload for web olatforms (using file bytes)
      else if (imageBytes != null) {
        emit(PostsUploading());
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
      }

      // give image url to post
      final Post newPost = post.copyWith(imageUrl: imageUrl);

      // create post in the backend
      await postRepo.createPost(newPost);

      emit(PostsUploaded());

      // re-fetch all posts
      fetchAllPosts();
    } catch (e) {
      emit(PostsError("Failed to create post: $e"));
    }
  }

  // fetch all posts
  Future<void> fetchAllPosts() async {
    try {
      emit(PostsLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError("Failed to fetch post: $e"));
    }
  }

  // delete a post
  Future<void> deletePost(String postId, String imageUrl) async {
    try {
      await postRepo.deletePost(postId);
      await storageRepo.deletePostImage(imageUrl);
    } catch (e) {
      emit(PostsError("Failed to delete Post $e"));
    }
  }

  // toggle like on a post
  Future<void> toggleLikePost(String postId, String userId, bool setIsLike) async {
    try {
      await postRepo.toggleLikePost(postId, userId,setIsLike);
    } catch (e) {
      emit(PostsError("Failed to toggle like: $e"));
    }
  }

  // add a comment to a post
  Future<void> addComment(String postId, Comment comment) async {
    try {
      await postRepo.addComment(postId, comment);
    } catch (e) {
      emit(PostsError("Failed to add comment: $e"));
    }
  }

  // delete comment from a post
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await postRepo.deleteComment(postId, commentId);
    } catch (e) {
      emit(PostsError("Failed to delete comment: $e"));
    }
  }
}
