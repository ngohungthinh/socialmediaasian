import 'package:social_media/features/posts/domain/entities/comment.dart';
import 'package:social_media/features/posts/domain/entities/post.dart';

abstract class PostRepo {
  Future<List<Post>> fetchAllPosts();
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  Future<List<Post>> fetchPostByUserId(String userid);
  Future<void> toggleLikePost(String postId, String userId, bool setIsLike);
  Future<void> addComment(String posstId, Comment comment);
  Future<void> deleteComment(String postId, String commentId);
}
