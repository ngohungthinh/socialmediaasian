import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_media/features/storage/domain/storage_repo.dart';

class FirebaseStorageRepo implements StorageRepo {
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  // mobile platform
  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, "profile_images");
  }

  // web platform
  @override
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileBytes(fileBytes, fileName, "profile_images");
  }

  // Image Post UPLOAD

  @override
  Future<String?> uploadPostImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, "post_images");
  }

  @override
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileBytes(fileBytes, fileName, "post_images");
  }

  // Delete Image
  @override
  Future<void> deletePostImage(String imageUrl) async {
    // find place to store
    final Reference storageRef =
        firebaseStorage.refFromURL(imageUrl);
    await storageRef.delete();
  }
  /*

  HELPER METHODS - to upload files to storage

  */

  // mobile platforms (file)
  Future<String?> _uploadFile(
      String path, String fileName, String folder) async {
    try {
      // get file
      final File file = File(path);

      // find place to store
      final Reference storageRef =
          firebaseStorage.ref().child('$folder/$fileName');

      // upload
      final TaskSnapshot uploadTask = await storageRef.putFile(file);

      // get image download url
      final String downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  // web platforms (bytes)
  Future<String?> _uploadFileBytes(
      Uint8List fileBytes, String fileName, String folder) async {
    try {
      // find place to store
      final Reference storageRef =
          firebaseStorage.ref().child('$folder/$fileName');

      // upload
      final TaskSnapshot uploadTask = await storageRef.putData(fileBytes);

      // get image download url
      final String downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }
}
