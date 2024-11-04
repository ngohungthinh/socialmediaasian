import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/features/posts/domain/entities/comment.dart';
import 'package:social_media/features/posts/domain/entities/post.dart';
import 'package:social_media/features/posts/domain/repos/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // store the posts in a collection called 'posts'
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection("posts");

  @override
  Future<void> createPost(Post post) async {
    try {
      await postsCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception("Error creating post: $e");
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await postsCollection.doc(postId).delete();
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      // get all postw with most recent posts at the top
      final QuerySnapshot<Object?> postsSnapshot = await postsCollection
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();
      final List<Post> allPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return allPosts;
    } catch (e) {
      throw Exception("Error fetch posts: $e");
    }
  }

  @override
  Future<List<Post>> fetchPostByUserId(String userId) async {
    try {
      // get all postw with most recent posts at the top
      final QuerySnapshot<Object?> postsSnapshot = await postsCollection
          .where('userId', isEqualTo: userId)
          .get();

      final List<Post> userPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return userPosts;
    } catch (e) {
      throw Exception("Error fetch posts by userID: $e");
    }
  }

  @override
  Future<void> toggleLikePost(
    String postId,
    String userId,
    bool setIsLike,
  ) async {
    try {
      if (setIsLike == true) {
        await postsCollection.doc(postId).update({
          'likes': FieldValue.arrayUnion([userId])
        });
      } else {
        await postsCollection.doc(postId).update({
          'likes': FieldValue.arrayRemove([userId])
        });
      }

      // // get the post document from firestore
      // final postDoc = await postsCollection.doc(postId).get();

      // if (postDoc.exists) {
      //   final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

      //   // check if user has already like this post
      //   final hasLiked = post.likes.contains(userId);

      //   // update the likes list
      //   if (hasLiked) {
      //     post.likes.remove(userId);
      //   } else {
      //     post.likes.add(userId);
      //   }

      //   // update the post document with the new like list
      //   await postsCollection.doc(postId).update({
      //     'likes': post.likes,
      //   });
      // } else {
      //   throw Exception("Post not found");
      // }
    } catch (e) {
      throw Exception("Error toggling like: $e");
    }
  }

  // COMMENT
  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      await postsCollection.doc(postId).update({
        'comments': FieldValue.arrayUnion([comment.toJson()])
      });
      // // get post document
      // final postDoc = await postsCollection.doc(postId).get();

      // if (postDoc.exists) {
      //   //convert json object -> post
      //   final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

      //   // add the new comment
      //   post.comments.add(comment);

      //   // update the post document in firestore
      //   await postsCollection.doc(postId).update({
      //     'comments': post.comments.map((comment) => comment.toJson()).toList(),
      //   });
      // } else {
      //   throw Exception("Post not found");
      // }
    } catch (e) {
      throw Exception("Error adding comment: $e");
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      // get post document
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        //convert json object -> post
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // add the new comment
        post.comments.removeWhere((comment) => comment.id == commentId);

        // update the post document in firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList(),
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error delete comment: $e");
    }
  }
}
