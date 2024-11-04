import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/domain/repos/profile_repo.dart';
import 'package:social_media/features/profile/presentation/cubits/profile_states.dart';
import 'package:social_media/features/storage/domain/storage_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit({required this.storageRepo, required this.profileRepo})
      : super(ProfileInitial());

  // fetch user profile using repo -> useful for loading single profile pages
  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      final ProfileUser? user = await profileRepo.fetchUserProfile(uid);

      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError("User not found"));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // return user profile given uid -> useful for loading many profiles for posts
  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepo.fetchUserProfile(uid);
    return user;
  }

  // update bio and/or profile picture
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    Uint8List? imageWebBytes,
    String? imageMobilePath,
  }) async {
    emit(ProfileLoading());
    try {
      // fetch current profile first
      final ProfileUser? currentUser = await profileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(ProfileError("Failed to fetch user for profile update"));
        return;
      }

      // profile picture update
      String? imageDownloadUrl;
      if (imageWebBytes != null || imageMobilePath != null) {
        if (imageWebBytes != null) {
          imageDownloadUrl =
              await storageRepo.uploadProfileImageWeb(imageWebBytes, uid);
        } else if (imageMobilePath != null) {
          imageDownloadUrl =
              await storageRepo.uploadProfileImageMobile(imageMobilePath, uid);
        }

        if (imageDownloadUrl == null) {
          emit(ProfileError("Failed to upload image"));
          return;
        }
      }
      //new profile
      final ProfileUser updatedProfile = currentUser.copyWith(
          newBio: newBio ?? currentUser.bio,
          newProfileImageUrl: imageDownloadUrl);

      // update in repo in FireBase
      await profileRepo.updateProfile(updatedProfile);

      //re-fetch the updated profile
      // await fetchUserProfile(uid);
      // Co cach nhanh hon la emit(ProfileLoaded(updatedProfile));
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(ProfileError("Error updating profile $e"));
    }
  }

  // toggle follow/unfollow
  Future<void> toggleFollow(
      String currentUserId, String targetUserId, bool setIsFollow) async {
    try {
      await profileRepo.toggleFollow(currentUserId, targetUserId, setIsFollow);
    } catch (e) {
      emit(ProfileError("Error toggling follow: $e"));
    }
  }
}
