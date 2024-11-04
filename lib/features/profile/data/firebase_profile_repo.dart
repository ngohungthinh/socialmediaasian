import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/domain/repos/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    try {
      // get user document from firestore
      final userDoc =
          await firebaseFirestore.collection("users").doc(uid).get();

      if (userDoc.exists) {
        final Map<String, dynamic>? userData = userDoc.data();

        if (userData != null) {
          return ProfileUser(
            uid: uid,
            email: userData['email'],
            name: userData['name'],
            bio: userData['bio'] ?? "",
            profileImageUrl: userData['profileImageUrl'].toString(),
            followers: List.from(userData['followers'] ?? []),
            following: List.from(userData['following'] ?? []),
          );
        }
      }

      return null;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updateProfile(ProfileUser updatedProfile) async {
    try {
      await firebaseFirestore
          .collection("users")
          .doc(updatedProfile.uid)
          .update(updatedProfile.toJson());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> toggleFollow(
      String currentUid, String targetUid, bool setIsFollow) async {
    try {
      if (setIsFollow == true) {
        firebaseFirestore.collection('users').doc(currentUid).update({
          'following': FieldValue.arrayUnion([targetUid])
        });

        firebaseFirestore.collection('users').doc(targetUid).update({
          'followers': FieldValue.arrayUnion([currentUid])
        });
      } else {
        firebaseFirestore.collection('users').doc(currentUid).update({
          'following': FieldValue.arrayRemove([targetUid])
        });

        firebaseFirestore.collection('users').doc(targetUid).update({
          'followers': FieldValue.arrayRemove([currentUid])
        });
      }

      // final currentUserDoc =
      //     await firebaseFirestore.collection('users').doc(currentUid).get();
      // final targetUserDoc =
      //     await firebaseFirestore.collection('users').doc(targetUid).get();

      // if (currentUserDoc.exists && targetUserDoc.exists) {
      //   final currentUserData = currentUserDoc.data();
      //   final targetUserData = targetUserDoc.data();

      //   if (currentUserData != null && targetUserData != null) {
      //     final List<String> currentFollowing =
      //         List.from(currentUserData['following'] ?? []);

      //     // check if the current user is already following the target user
      //     if (currentFollowing.contains(targetUid)) {
      //       // do đang follow nên chuyển thành unfollow
      //       await firebaseFirestore.collection('users').doc(currentUid).update({
      //         'following': FieldValue.arrayRemove([targetUid])
      //       });

      //       await firebaseFirestore.collection('users').doc(targetUid).update({
      //         'followers': FieldValue.arrayRemove([currentUid])
      //       });
      //     } else {
      //       await firebaseFirestore.collection('users').doc(currentUid).update({
      //         'following': FieldValue.arrayUnion([targetUid])
      //       });

      //       await firebaseFirestore.collection('users').doc(targetUid).update({
      //         'followers': FieldValue.arrayUnion([currentUid])
      //       });
      //     }
      //   }
      // }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
