import 'package:social_media/features/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final String bio;
  final String profileImageUrl;
  final List<String> followers;
  final List<String> following;

  ProfileUser(
      {required super.uid,
      required super.email,
      required super.name,
      required this.bio,
      required this.profileImageUrl,
      required this.followers,
      required this.following});

  // method to update profile user
  ProfileUser copyWith({
    String? newBio,
    String? newProfileImageUrl,
    List<String>? newFollower,
    List<String>? newFollowing,
  }) {
    return ProfileUser(
      bio: newBio ?? bio,
      profileImageUrl: newProfileImageUrl ?? profileImageUrl,
      uid: uid,
      email: email,
      name: name,
      followers: newFollower ?? followers,
      following: newFollowing ?? following,
    );
  }

  // convert profile user --> json
  @override
  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      'name': name,
      'email': email,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'followers': followers,
      'following': following,
    };
  }

  // convert json --> profile user
  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      bio: json['bio'] ?? "",
      profileImageUrl: json['profileImageUrl'] ?? "",
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      followers: List.from( json['followers'] ?? []),
      following: List.from (json['following'] ?? []),
    );
  }
}
