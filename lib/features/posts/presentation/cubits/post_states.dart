import 'package:social_media/features/posts/domain/entities/post.dart';

abstract class PostState {}

// initial
class PostsInitial extends PostState {}

// loading...
class PostsLoading extends PostState {}

// uploading...
class PostsUploading extends PostState {}

// uploaded...
class PostsUploaded extends PostState {}

// error
class PostsError extends PostState {
  final String message;
  PostsError(this.message);
}

// loaded
class PostsLoaded extends PostState {
  final List<Post> posts;
  PostsLoaded(this.posts);
}
