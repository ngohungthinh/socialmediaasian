import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media/features/auth/domain/entities/app_user.dart';
import 'package:social_media/features/auth/presentation/components/my_textfield.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/posts/domain/entities/post.dart';
import 'package:social_media/features/posts/presentation/cubits/post_cubit.dart';
import 'package:social_media/features/posts/presentation/cubits/post_states.dart';
import 'package:social_media/responsive/widget_max_width_465.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  // mobile image pick
  PlatformFile? imagePickerFile;

  // web image pick
  Uint8List? webImage;

  // text controller -> caption
  final textController = TextEditingController();

  // current user
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  // get current user
  void getCurrentUser() async {
    final AuthCubit authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  // pick image
  Future<void> pickImage() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
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

  // create & upload post
  void uploadPost() {
    // check if both image and caption are provided
    if (imagePickerFile == null || textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Both image and caption are required")));
      return;
    }

    // create a new post object
    final newPost = Post(
        id: Timestamp.now().millisecondsSinceEpoch.toString(),
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: textController.text,
        imageUrl: "",
        timestamp: DateTime.now(),
        likes: [],
        comments: []);

    // post cubit
    final postCubit = context.read<PostCubit>();

    // web upload
    if (kIsWeb) {
      postCubit.createPost(newPost, imageBytes: imagePickerFile?.bytes);
    }
    // mobile upload
    else {
      postCubit.createPost(newPost, imagePath: imagePickerFile?.path);
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      // 2 truong hop
      builder: (context, state) {
        print(state);
        // loading or uploading...
        if (state is PostsLoading || state is PostsUploading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        // build upload page
        else {
          return buildUploadPage();
        }
      },
      listener: (context, state) {
        if (state is PostsUploaded) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  Widget buildUploadPage() {
    return WidgetMaxWidth465(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Create Post"),
          foregroundColor: Theme.of(context).colorScheme.primary,
          actions: [
            IconButton(onPressed: uploadPost, icon: const Icon(Icons.upload))
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // image preview for web
                if (kIsWeb && webImage != null)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 600),
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: Image.memory(
                        webImage!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                // image preview for moible
                if (!kIsWeb && imagePickerFile != null)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 600),
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      child: Image.file(
                        File(imagePickerFile!.path!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                const SizedBox(
                  height: 10,
                ),

                // pick image button
                MaterialButton(
                  onPressed: pickImage,
                  color: Colors.blue,
                  child: const Text("Pick Image"),
                ),

                const SizedBox(
                  height: 10,
                ),

                // caption text box
                MyTextfield(
                  hintText: "Caption",
                  obscureText: false,
                  controller: textController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
