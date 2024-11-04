import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media/features/auth/data/firebase_auth_repo.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media/features/auth/presentation/cubits/auth_states.dart';
import 'package:social_media/features/auth/presentation/pages/auth_page.dart';
import 'package:social_media/features/home/presentation/pages/home_page.dart';
import 'package:social_media/features/posts/data/firebase_post_repo.dart';
import 'package:social_media/features/posts/presentation/cubits/post_cubit.dart';
import 'package:social_media/features/profile/data/firebase_profile_repo.dart';
import 'package:social_media/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media/features/search/data/firebase_search_repo.dart';
import 'package:social_media/features/search/presentation/cubits/search_cubit.dart';
import 'package:social_media/themes/theme_cubit.dart';
import 'features/storage/data/firebase_storage_repo.dart';

/*

Repositories: for the database
  - firebase

Bloc Providers: for state management
  - auth
  - profile
  - post
  - search
  - theme

Check Auth State
  - unauthenticated -> auth page (login/register)
  - authenticated -> home page

*/

class MyApp extends StatelessWidget {
  final FirebaseAuthRepo firebaseAuthRepo = FirebaseAuthRepo();
  final FirebaseProfileRepo firebaseProfileRepo = FirebaseProfileRepo();
  final FirebaseStorageRepo firebaseStorageRepo = FirebaseStorageRepo();
  final FirebasePostRepo firebasePostRepo = FirebasePostRepo();
  final FirebaseSearchRepo firebaseSearchRepo = FirebaseSearchRepo();
  final SharedPreferences sharedPreferences;
  MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) =>
                AuthCubit(authRepo: firebaseAuthRepo)..checkAuth()),
        BlocProvider(
          create: (context) => ProfileCubit(
            profileRepo: firebaseProfileRepo,
            storageRepo: firebaseStorageRepo,
          ),
        ),
        // post cubit
        BlocProvider(
            create: (context) => PostCubit(
                postRepo: firebasePostRepo, storageRepo: firebaseStorageRepo)),
        // search cubit
        BlocProvider(
            create: (context) => SearchCubit(searchRepo: firebaseSearchRepo)),

        // theme cubit
        BlocProvider(
            create: (context) => ThemeCubit(sharedPreferences,
                sharedPreferences.getBool('isDarkMode') ?? false)),
      ],
      // Check Theme
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, state) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: state,

          // Check Auth
          home: BlocConsumer<AuthCubit, AuthState>(
            builder: (context, authState) {
              // unauthenticated -> auth page (login/register)
              if (authState is Unauthenticated) {
                return AuthPage(
                  showLoginPage: authState.showLoginPage,
                );
              }

              // authenticated -> homepage
              else if (authState is Authenticated) {
                return const HomePage();
              }

              // loading
              else {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },

            // listen for errors....
            listener: (context, authState) {
              if (authState is AuthError) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(authState.message)));
              }
            },
          ),
        ),
      ),
    );
  }
}
