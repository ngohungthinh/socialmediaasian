import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/presentation/components/my_textfield.dart';
import 'package:social_media/features/profile/domain/entities/profile_user.dart';
import 'package:social_media/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media/features/profile/presentation/cubits/profile_states.dart';
import 'package:social_media/responsive/widget_max_width_465.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // mobile image pick
  PlatformFile? imagePickerFile;

  // Web image pick
  Uint8List? webImage;

  // bio controller
  final bioTextController = TextEditingController();

  // pick image
  Future<void> pickImage() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    // Open FilePicker de khong bi spam click
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        withData: kIsWeb,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif']);
    if (mounted) {
      Navigator.pop(context);
    }

    if (result != null) {
      final fileExtension = result.files.first.extension;
      if (fileExtension == 'jpg' ||
          fileExtension == 'jpeg' ||
          fileExtension == 'png' ||
          fileExtension == 'gif') {
        setState(() {
          imagePickerFile = result.files.first;

          // Neu day la web
          if (kIsWeb) {
            webImage = imagePickerFile!.bytes;
          }
        });
      }
    }
  }

  // update profile button pressed
  void updateProfile() async {
    //profile cubit
    final profileCubit = context.read<ProfileCubit>();

    // prepare images & data
    final String uid = widget.user.uid;
    final String? newBio =
        bioTextController.text.isNotEmpty ? bioTextController.text : null;
    final imageMobilePath = kIsWeb ? null : imagePickerFile?.path;
    final iamgeWebBytes = kIsWeb ? imagePickerFile?.bytes : null;

    // only update profile if there is something to update
    if (imagePickerFile != null || newBio != null) {
      profileCubit.updateProfile(
        uid: uid,
        newBio: newBio,
        imageMobilePath: imageMobilePath,
        imageWebBytes: iamgeWebBytes,
      );
    }

    // nothing to update
    else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WidgetMaxWidth465(
      child: BlocConsumer<ProfileCubit, ProfileState>(
        builder: (context, state) {
          // profile loading...
          if (state is ProfileLoading) {
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text("Uploading..."),
                  ],
                ),
              ),
            );
          } else {
            // edit form
            return buildEditPage();
          }
        },
        listener: (context, state) {
          if (state is ProfileLoading) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget buildEditPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          // save button
          IconButton(
            onPressed: updateProfile,
            icon: const Icon(
              Icons.upload,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // profile picture
          Container(
            width: 200,
            height: 200,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.secondary),
            // 3 trường hợp
            child:
                // display selected image for mobile
                (!kIsWeb && imagePickerFile != null)
                    ? Image.file(
                        File(imagePickerFile!.path!),
                        fit: BoxFit.cover,
                      )
                    :
                    // display selected image for web
                    (kIsWeb && webImage != null)
                        ? Image.memory(
                            webImage!,
                            fit: BoxFit.cover,
                          )
                        :
                        // no image selected -> display existing profile bic
                        CachedNetworkImage(
                            imageUrl: widget.user.profileImageUrl,
                            // loading...
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),

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
          const SizedBox(
            height: 10,
          ),

          MaterialButton(
            onPressed: pickImage,
            color: Colors.blue,
            child: const Text("Pick Image"),
          ),

          const SizedBox(
            height: 10,
          ),

          // bio
          const Text("Bio"),

          const SizedBox(
            height: 10,
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: MyTextfield(
              hintText: widget.user.bio,
              obscureText: false,
              controller: bioTextController,
            ),
          ),
        ],
      ),
    );
  }
}
